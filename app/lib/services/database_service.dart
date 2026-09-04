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

    const int _kExpectedDbVersion = 6;

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'ati_data.db');
    final dbFile = File(dbPath);

    bool needsCopy = !await dbFile.exists() || await dbFile.length() < 1000000;

    // Check user_version of the installed DB; re-copy if outdated.
    if (!needsCopy) {
      try {
        final checkDb = await openDatabase(dbPath, readOnly: true);
        final versionResult = await checkDb.rawQuery('PRAGMA user_version');
        final installedVersion = versionResult.first.values.first as int? ?? 0;
        await checkDb.close();
        if (installedVersion < _kExpectedDbVersion) needsCopy = true;
      } catch (_) {
        needsCopy = true;
      }
    }

    if (needsCopy) {
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

    final db = await openDatabase(dbPath, readOnly: false, singleInstance: true);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_default INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
    // Migrate: add is_default column to existing installs
    try {
      await db.execute('ALTER TABLE collections ADD COLUMN is_default INTEGER DEFAULT 0');
    } catch (_) {}
    await db.execute('''
      CREATE TABLE IF NOT EXISTS collection_items (
        collection_id INTEGER NOT NULL,
        text_id TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        PRIMARY KEY (collection_id, text_id),
        FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE
      )
    ''');
    // Seed the "Saved" default collection if it doesn't exist yet
    final savedRows = await db.query('collections', where: 'is_default = 1', limit: 1);
    if (savedRows.isEmpty) {
      final savedId = await db.insert('collections', {
        'name': 'Saved',
        'is_default': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      // Migrate any existing bookmarks into the Saved collection
      final bmCheck = await db.rawQuery(
        "SELECT COUNT(*) as c FROM sqlite_master WHERE type='table' AND name='bookmarks'",
      );
      final hasBm = (bmCheck.first['c'] as int? ?? 0);
      if (hasBm > 0) {
        await db.rawInsert('''
          INSERT OR IGNORE INTO collection_items (collection_id, text_id, added_at)
          SELECT ?, text_id, created_at FROM bookmarks
        ''', [savedId]);
        await db.execute('DROP TABLE bookmarks');
      }
    }
    return db;
  }

  Future<int> _savedCollectionId() async {
    final db = await database;
    final rows = await db.query('collections', columns: ['id'], where: 'is_default = 1', limit: 1);
    return rows.first['id'] as int;
  }

  // --- Collections ---
  Future<List<Map<String, dynamic>>> getCollections() async {
    final db = await database;
    return (await db.query('collections', orderBy: 'created_at ASC'))
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  Future<int> createCollection(String name, {String? description}) async {
    final db = await database;
    return db.insert('collections', {
      'name': name,
      'description': description,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateCollection(int id, String name, {String? description}) async {
    final db = await database;
    await db.update(
      'collections',
      {'name': name, 'description': description},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete('collections', where: 'id = ?', whereArgs: [id]);
    await db.delete('collection_items', where: 'collection_id = ?', whereArgs: [id]);
  }

  Future<List<TextItem>> getCollectionItems(int collectionId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT texts.* FROM collection_items
      JOIN texts ON texts.id = collection_items.text_id
      WHERE collection_items.collection_id = ?
      ORDER BY collection_items.added_at ASC
    ''', [collectionId]);
    return rows.map((e) => Map<String, dynamic>.from(e)).map(TextItem.fromMap).toList();
  }

  Future<Set<int>> getCollectionIdsForText(String textId) async {
    final db = await database;
    final rows = await db.query('collection_items',
        columns: ['collection_id'], where: 'text_id = ?', whereArgs: [textId]);
    return rows.map((r) => r['collection_id'] as int).toSet();
  }

  Future<void> addToCollection(int collectionId, String textId) async {
    final db = await database;
    await db.insert('collection_items', {
      'collection_id': collectionId,
      'text_id': textId,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFromCollection(int collectionId, String textId) async {
    final db = await database;
    await db.delete('collection_items',
        where: 'collection_id = ? AND text_id = ?', whereArgs: [collectionId, textId]);
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

  // --- All Texts (metadata only — no content_html/content_plain) ---
  Future<List<TextItem>> getAllTextsMetadata() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT rowid, id, path, title, subtitle, sutta_ref, nikaya, nikaya_abbrev,
             collection, author, author_short, pts_id, type, summary,
             word_count, year, license
      FROM texts
      ORDER BY nikaya_abbrev ASC, collection ASC, title ASC
    ''');
    return rows.map((e) => TextItem.fromMap(e)).toList();
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

    // 1. Sutta ref short match e.g. "DN 11" or "MN 10"
    final exactRef = await db.query(
      'texts',
      where: 'sutta_ref LIKE ?',
      whereArgs: ['%$cleanQ%'],
      limit: limit,
    );
    if (exactRef.isNotEmpty && cleanQ.length <= 10) {
      return exactRef.map((e) => TextItem.fromMap(e)).toList();
    }

    // 2. Title LIKE match — always the highest priority bucket
    final titleRows = await db.query(
      'texts',
      where: 'title LIKE ?',
      whereArgs: ['%$cleanQ%'],
      limit: limit,
    );
    final titleIds = {for (final r in titleRows) r['id'] as String};

    // 3. FTS5 full-text search for the remainder
    List<Map<String, dynamic>> ftsRows = [];
    try {
      final ftsQuery = cleanQ.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      if (ftsQuery.isNotEmpty) {
        final raw = await db.rawQuery('''
          SELECT texts.* FROM search_index
          JOIN texts ON texts.rowid = search_index.rowid
          WHERE search_index MATCH ?
          ORDER BY bm25(search_index, 10, 3, 5, 2, 1, 1)
          LIMIT ?
        ''', ['$ftsQuery*', limit]);
        ftsRows = raw.where((r) => !titleIds.contains(r['id'] as String)).toList();
      }
    } catch (e) {
      debugPrint('FTS search fallback to LIKE: $e');
      // Fallback: LIKE on all fields, excluding already-found titles
      final likeRows = await db.query(
        'texts',
        where: 'title NOT LIKE ? AND (summary LIKE ? OR author LIKE ? OR content_plain LIKE ?)',
        whereArgs: ['%$cleanQ%', '%$cleanQ%', '%$cleanQ%', '%$cleanQ%'],
        limit: limit,
      );
      ftsRows = likeRows;
    }

    final combined = [...titleRows, ...ftsRows];
    return combined.take(limit).map((e) => TextItem.fromMap(e)).toList();
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
    // Group by author_short for consistent counts, use authors table for canonical name.
    // Exclude lib/authors/*/index.html pages — they are author bios indexed as stubs, not real texts.
    final rows = await db.rawQuery('''
      SELECT t.author_short,
             COALESCE(a.name, MIN(CASE WHEN t.author != '' THEN t.author ELSE NULL END)) as author,
             COUNT(*) as text_count
      FROM texts t
      LEFT JOIN authors a ON lower(a.author_short) = lower(t.author_short)
                          OR a.slug = lower(t.author_short)
      WHERE t.author_short != ''
        AND t.author_short != 'Anonymous'
        AND t.author_short != 'Various authors'
        AND t.path NOT GLOB 'lib/authors/*/index.html'
      GROUP BY t.author_short
      HAVING author IS NOT NULL AND author != ''
      ORDER BY text_count DESC
    ''');
    return rows;
  }

  Future<List<TextItem>> getTextsByAuthor(String authorShort) async {
    final db = await database;
    final rows = await db.rawQuery(
      "SELECT * FROM texts WHERE author_short = ? AND path NOT GLOB 'lib/authors/*/index.html' ORDER BY title ASC",
      [authorShort],
    );
    return rows.map((e) => TextItem.fromMap(e)).toList();
  }

  Future<Map<String, dynamic>?> getAuthorBio(String authorShort) async {
    try {
      final db = await database;
      // Primary lookup: author_short column (back-filled during DB build)
      var rows = await db.rawQuery(
        'SELECT * FROM authors WHERE lower(author_short) = ? LIMIT 1',
        [authorShort.toLowerCase()],
      );
      // Fallback: slug exact match
      if (rows.isEmpty) {
        rows = await db.query('authors', where: 'slug = ?', whereArgs: [authorShort.toLowerCase()], limit: 1);
      }
      return rows.isNotEmpty ? rows.first : null;
    } catch (e) {
      debugPrint('getAuthorBio error: $e');
      return null;
    }
  }

  // --- Study Guides ---
  Future<List<TextItem>> getStudyGuides() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT * FROM texts
      WHERE collection = 'study'
        AND (
          path NOT LIKE 'lib/study/%/%'
          OR path LIKE 'lib/study/%/index.html'
        )
        AND path != 'lib/study/index.html'
        AND path != 'lib/study/beyondcoping.html'
      ORDER BY title ASC
    ''');
    return rows.map((e) => Map<String, dynamic>.from(e)).map((e) => TextItem.fromMap(e)).toList();
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
  // "Bookmark" = saved to the default Saved collection.
  Future<bool> isBookmarked(String textId) async {
    final savedId = await _savedCollectionId();
    final db = await database;
    final rows = await db.query('collection_items',
        where: 'collection_id = ? AND text_id = ?', whereArgs: [savedId, textId], limit: 1);
    return rows.isNotEmpty;
  }

  Future<bool> toggleBookmark(String textId) async {
    final savedId = await _savedCollectionId();
    final exists = await isBookmarked(textId);
    if (exists) {
      await removeFromCollection(savedId, textId);
      return false;
    } else {
      await addToCollection(savedId, textId);
      return true;
    }
  }

  Future<void> updateReadingProgress(String textId, double progress) async {
    final db = await database;
    await db.rawInsert('''
      INSERT OR REPLACE INTO reading_history (text_id, progress, last_read_at)
      VALUES (?, ?, ?)
    ''', [textId, progress, DateTime.now().millisecondsSinceEpoch]);
  }

  Future<void> deleteHistoryEntry(String textId) async {
    final db = await database;
    await db.rawDelete(
      'DELETE FROM reading_history WHERE text_id = ?',
      [textId],
    );
  }

  Future<List<Map<String, dynamic>>> getRecentReadingHistory({int limit = 10}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT texts.id AS text_id, texts.title, texts.subtitle, texts.sutta_ref, texts.nikaya_abbrev,
             reading_history.progress, reading_history.last_read_at
      FROM reading_history
      JOIN texts ON texts.id = reading_history.text_id
      ORDER BY reading_history.last_read_at DESC
      LIMIT ?
    ''', [limit]);
    // Return a mutable copy — sqflite's QueryResultSet is read-only
    return rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }
}
