import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/text_item.dart';
import '../models/glossary_item.dart';
import '../models/simile_item.dart';
import '../models/subject_item.dart';
import '../models/dhp_verse.dart';
import '../models/ptf_section.dart';
import '../models/daily_contemplation.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _db;
  final ValueNotifier<String> initStatusNotifier = ValueNotifier<String>('Initializing...');
  final ValueNotifier<double> initProgressNotifier = ValueNotifier<double>(0.0);

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'ati_data.db');
    final dbFile = File(dbPath);

    if (!await dbFile.exists() || await dbFile.length() < 1000000) {
      initStatusNotifier.value = 'Preparing Access to Insight canon...';
      initProgressNotifier.value = 0.2;

      // Check if uncompressed or gzipped asset is present
      try {
        final gzByteData = await rootBundle.load('assets/ati_data.db.gz');
        initStatusNotifier.value = 'Unpacking teachings (1,800+ suttas)...';
        initProgressNotifier.value = 0.5;

        final gzippedBytes = gzByteData.buffer.asUint8List();
        final decompressed = gzip.decode(gzippedBytes);

        initStatusNotifier.value = 'Saving canonical database...';
        initProgressNotifier.value = 0.8;
        await dbFile.writeAsBytes(decompressed, flush: true);
      } catch (e) {
        // Fallback: check if uncompressed db was bundled
        try {
          final dbByteData = await rootBundle.load('assets/ati_data.db');
          await dbFile.writeAsBytes(dbByteData.buffer.asUint8List(), flush: true);
        } catch (e2) {
          debugPrint('Error unpacking db asset: $e2');
        }
      }
    }

    initProgressNotifier.value = 1.0;
    initStatusNotifier.value = 'Ready';

    return await openDatabase(
      dbPath,
      readOnly: false,
      singleInstance: true,
    );
  }

  // --- Tipitaka Counters ---
  Future<Map<String, int>> getTipitakaCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT nikaya_abbrev, COUNT(*) as count 
      FROM texts 
      WHERE collection IN ('dn', 'mn', 'sn', 'an') OR collection LIKE 'kn%' OR collection = 'vinaya' OR collection = 'abhidhamma'
      GROUP BY nikaya_abbrev
    ''');

    final map = <String, int>{};
    for (final row in res) {
      map[row['nikaya_abbrev'] as String] = row['count'] as int;
    }
    return map;
  }

  // --- Text Queries ---
  Future<List<TextItem>> getTextsByNikaya(String nikayaAbbrev, {int limit = 100, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'texts',
      where: 'nikaya_abbrev = ?',
      whereArgs: [nikayaAbbrev],
      orderBy: 'rowid ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => TextItem.fromMap(e)).toList();
  }

  Future<List<TextItem>> getTextsByCollection(String collectionPrefix, {int limit = 100, int offset = 0}) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'texts',
      where: 'collection = ? OR collection LIKE ?',
      whereArgs: [collectionPrefix, '$collectionPrefix/%'],
      orderBy: 'rowid ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map((e) => TextItem.fromMap(e)).toList();
  }

  Future<TextItem?> getTextById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'texts',
      where: 'id = ? OR path = ?',
      whereArgs: [id, id],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return TextItem.fromMap(rows.first);
    }
    return null;
  }

  Future<TextItem?> getRandomText({String? type, String? nikayaAbbrev}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClause += 'type = ?';
      whereArgs.add(type);
    }
    if (nikayaAbbrev != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'nikaya_abbrev = ?';
      whereArgs.add(nikayaAbbrev);
    }

    final List<Map<String, dynamic>> rows = await db.query(
      'texts',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return TextItem.fromMap(rows.first);
    }
    return null;
  }

  // --- Search with FTS5 and LIKE fallback ---
  Future<List<TextItem>> searchTexts(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final db = await database;
    final cleanQ = query.trim();

    // 1. Try Sutta Ref match e.g. "DN 11" or "MN 10" or "SN 56"
    final exactRef = await db.query(
      'texts',
      where: 'sutta_ref LIKE ? OR title LIKE ?',
      whereArgs: ['%$cleanQ%', '%$cleanQ%'],
      limit: limit,
    );
    if (exactRef.isNotEmpty && cleanQ.length <= 10) {
      return exactRef.map((e) => TextItem.fromMap(e)).toList();
    }

    // 2. FTS5 Search
    try {
      final ftsQuery = cleanQ.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      if (ftsQuery.isNotEmpty) {
        final ftsRows = await db.rawQuery('''
          SELECT texts.* FROM search_index
          JOIN texts ON texts.rowid = search_index.rowid
          WHERE search_index MATCH ?
          LIMIT ?
        ''', ['$ftsQuery*', limit]);

        if (ftsRows.isNotEmpty) {
          return ftsRows.map((e) => TextItem.fromMap(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('FTS search fallback to LIKE: $e');
    }

    // 3. Fallback LIKE search
    final likeRows = await db.query(
      'texts',
      where: 'title LIKE ? OR summary LIKE ? OR author LIKE ? OR content_plain LIKE ?',
      whereArgs: ['%$cleanQ%', '%$cleanQ%', '%$cleanQ%', '%$cleanQ%'],
      limit: limit,
    );
    return likeRows.map((e) => TextItem.fromMap(e)).toList();
  }

  // --- Thai Forest Tradition Masters ---
  Future<List<Map<String, dynamic>>> getThaiForestMasters() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT collection, COUNT(*) as text_count, MIN(author) as author_name
      FROM texts
      WHERE collection LIKE 'thai/%'
      GROUP BY collection
      ORDER BY text_count DESC
    ''');
    return rows;
  }

  // --- Authors Directory ---
  Future<List<Map<String, dynamic>>> getAuthorsDirectory() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT author, author_short, COUNT(*) as text_count
      FROM texts
      WHERE author != '' AND author != 'Anonymous'
      GROUP BY author
      ORDER BY text_count DESC
    ''');
    return rows;
  }

  Future<List<TextItem>> getTextsByAuthor(String author, {int limit = 100}) async {
    final db = await database;
    final rows = await db.query(
      'texts',
      where: 'author = ? OR author_short = ?',
      whereArgs: [author, author],
      orderBy: 'title ASC',
      limit: limit,
    );
    return rows.map((e) => TextItem.fromMap(e)).toList();
  }

  // --- Study Guides ---
  Future<List<TextItem>> getStudyGuides() async {
    final db = await database;
    final rows = await db.query(
      'texts',
      where: 'collection = ? OR path LIKE ?',
      whereArgs: ['study', 'lib/study/%'],
      orderBy: 'title ASC',
    );
    return rows.map((e) => TextItem.fromMap(e)).toList();
  }

  // --- Path to Freedom Sections ---
  Future<List<PtfSection>> getPtfSections() async {
    final db = await database;
    final rows = await db.query('ptf_sections', orderBy: 'step_order ASC');
    return rows.map((e) => PtfSection.fromMap(e)).toList();
  }

  // --- Daily Contemplations ---
  Future<DailyContemplation?> getDailyContemplation({int? dayOfYear}) async {
    final db = await database;
    final now = DateTime.now();
    final day = dayOfYear ?? (now.difference(DateTime(now.year, 1, 1)).inDays % 7 + 1);

    final rows = await db.query(
      'daily_contemplations',
      where: 'day_of_year = ?',
      whereArgs: [day],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return DailyContemplation.fromMap(rows.first);
    }
    // Fallback to first contemplation
    final all = await db.query('daily_contemplations', limit: 1);
    if (all.isNotEmpty) return DailyContemplation.fromMap(all.first);
    return null;
  }

  // --- Glossary Queries ---
  Future<List<GlossaryItem>> getGlossaryItems({String? query, String? letter}) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (query != null && query.trim().isNotEmpty) {
      whereClause = 'term LIKE ? OR pali_term LIKE ? OR definition LIKE ?';
      final q = '%${query.trim().toLowerCase()}%';
      whereArgs = [q, q, q];
    } else if (letter != null && letter.isNotEmpty) {
      whereClause = 'term LIKE ?';
      whereArgs = ['${letter.toLowerCase()}%'];
    }

    final rows = await db.query(
      'glossary',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'pali_term ASC',
    );
    return rows.map((e) => GlossaryItem.fromMap(e)).toList();
  }

  // --- Similes Queries ---
  Future<List<SimileItem>> getSimiles({String? query}) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (query != null && query.trim().isNotEmpty) {
      whereClause = 'simile LIKE ? OR meaning LIKE ? OR sutta_ref LIKE ?';
      final q = '%${query.trim()}%';
      whereArgs = [q, q, q];
    }

    final rows = await db.query(
      'similes',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'simile ASC',
    );
    return rows.map((e) => SimileItem.fromMap(e)).toList();
  }

  // --- Subjects Queries ---
  Future<List<SubjectItem>> getSubjects({String? query}) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (query != null && query.trim().isNotEmpty) {
      whereClause = 'subject LIKE ? OR details LIKE ?';
      final q = '%${query.trim()}%';
      whereArgs = [q, q];
    }

    final rows = await db.query(
      'subjects',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'subject ASC',
    );
    return rows.map((e) => SubjectItem.fromMap(e)).toList();
  }

  // --- Dhammapada Queries ---
  Future<List<Map<String, dynamic>>> getDhammapadaChapters() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT chapter_num, chapter_title, COUNT(*) as verse_groups, MIN(verse_num) as min_verse, MAX(verse_num) as max_verse
      FROM dhammapada_verses
      GROUP BY chapter_num, chapter_title
      ORDER BY chapter_num ASC
    ''');
    return rows;
  }

  Future<List<DhpVerse>> getDhammapadaVerses(int chapterNum) async {
    final db = await database;
    final rows = await db.query(
      'dhammapada_verses',
      where: 'chapter_num = ?',
      whereArgs: [chapterNum],
      orderBy: 'verse_num ASC',
    );
    return rows.map((e) => DhpVerse.fromMap(e)).toList();
  }

  // --- User Bookmarks & History ---
  Future<bool> isBookmarked(String textId) async {
    final db = await database;
    final rows = await db.query('bookmarks', where: 'text_id = ?', whereArgs: [textId], limit: 1);
    return rows.isNotEmpty;
  }

  Future<bool> toggleBookmark(String textId, {String? note}) async {
    final db = await database;
    final exists = await isBookmarked(textId);
    if (exists) {
      await db.delete('bookmarks', where: 'text_id = ?', whereArgs: [textId]);
      return false;
    } else {
      await db.insert('bookmarks', {
        'text_id': textId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'note': note,
      });
      return true;
    }
  }

  Future<List<TextItem>> getBookmarkedTexts() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT texts.* FROM bookmarks
      JOIN texts ON texts.id = bookmarks.text_id
      ORDER BY bookmarks.created_at DESC
    ''');
    return rows.map((e) => TextItem.fromMap(e)).toList();
  }

  Future<void> updateReadingProgress(String textId, double progress) async {
    final db = await database;
    await db.rawInsert('''
      INSERT OR REPLACE INTO reading_history (text_id, progress, last_read_at)
      VALUES (?, ?, ?)
    ''', [textId, progress, DateTime.now().millisecondsSinceEpoch]);
  }

  Future<List<Map<String, dynamic>>> getRecentReadingHistory({int limit = 10}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT texts.id, texts.title, texts.subtitle, texts.sutta_ref, texts.nikaya_abbrev,
             reading_history.progress, reading_history.last_read_at
      FROM reading_history
      JOIN texts ON texts.id = reading_history.text_id
      ORDER BY reading_history.last_read_at DESC
      LIMIT ?
    ''', [limit]);
    return rows;
  }
}
