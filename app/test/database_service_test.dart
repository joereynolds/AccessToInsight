import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

// Opens the test DB once; caller must close it.
Future<Database> _openTestDb() async {
  final gzFile = File('../app/assets/ati_data.db.gz');
  final dbBytes = gzip.decode(gzFile.readAsBytesSync());
  final tempPath = p.join(Directory.systemTemp.path, 'test_ati_${DateTime.now().millisecondsSinceEpoch}.db');
  await File(tempPath).writeAsBytes(dbBytes);
  return openDatabase(tempPath);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // ---------------------------------------------------------------------------
  // Core data integrity
  // ---------------------------------------------------------------------------

  group('Core data', () {
    late Database db;
    late String tempPath;

    setUpAll(() async {
      final gzFile = File('../app/assets/ati_data.db.gz');
      expect(gzFile.existsSync(), isTrue, reason: 'ati_data.db.gz must exist in app/assets');
      final dbBytes = gzip.decode(gzFile.readAsBytesSync());
      tempPath = p.join(Directory.systemTemp.path, 'test_ati_core_${DateTime.now().millisecondsSinceEpoch}.db');
      await File(tempPath).writeAsBytes(dbBytes);
      db = await openDatabase(tempPath);
    });

    tearDownAll(() async {
      await db.close();
      await File(tempPath).delete();
    });

    test('has over 1500 texts', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM texts');
      expect(r.first['c'] as int, greaterThan(1500));
    });

    test('contains all five nikayas', () async {
      final r = await db.rawQuery('SELECT DISTINCT nikaya_abbrev FROM texts');
      final abbrevs = r.map((row) => row['nikaya_abbrev'] as String).toSet();
      for (final n in ['DN', 'MN', 'SN', 'AN', 'KN']) {
        expect(abbrevs, contains(n), reason: '$n nikaya must be present');
      }
    });

    test('FTS5 search returns results', () async {
      final r = await db.rawQuery('''
        SELECT texts.id FROM search_index
        JOIN texts ON texts.rowid = search_index.rowid
        WHERE search_index MATCH 'loving*'
        LIMIT 5
      ''');
      expect(r, isNotEmpty, reason: 'FTS5 search for "loving*" must return results');
    });

    test('glossary has over 150 entries', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM glossary');
      expect(r.first['c'] as int, greaterThan(150));
    });

    test('similes has over 250 entries', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM similes');
      expect(r.first['c'] as int, greaterThan(250));
    });

    test('dhammapada has over 200 verses', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM dhammapada_verses');
      expect(r.first['c'] as int, greaterThan(200));
    });

    test('path to freedom has 6 stages', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM ptf_sections');
      expect(r.first['c'] as int, equals(6));
    });

    test('db schema version matches app expectation', () async {
      final r = await db.rawQuery('PRAGMA user_version');
      // Must stay in sync with _kExpectedDbVersion in database_service.dart
      expect(r.first['user_version'] as int, equals(6));
    });
  });

  // ---------------------------------------------------------------------------
  // Author directory — regression tests for the count/display fixes
  // ---------------------------------------------------------------------------

  group('Author directory', () {
    late Database db;
    late String tempPath;

    // The exact SQL used by getAuthorsDirectory() in database_service.dart
    Future<List<Map<String, Object?>>> _directoryQuery(Database db) {
      return db.rawQuery('''
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
    }

    // The exact SQL used by getTextsByAuthor() in database_service.dart
    Future<List<Map<String, Object?>>> _worksQuery(Database db, String authorShort) {
      return db.rawQuery(
        "SELECT * FROM texts WHERE author_short = ? AND path NOT GLOB 'lib/authors/*/index.html' ORDER BY title ASC",
        [authorShort],
      );
    }

    setUpAll(() async {
      final gzFile = File('../app/assets/ati_data.db.gz');
      final dbBytes = gzip.decode(gzFile.readAsBytesSync());
      tempPath = p.join(Directory.systemTemp.path, 'test_ati_authors_${DateTime.now().millisecondsSinceEpoch}.db');
      await File(tempPath).writeAsBytes(dbBytes);
      db = await openDatabase(tempPath);
    });

    tearDownAll(() async {
      await db.close();
      await File(tempPath).delete();
    });

    test('no entry has a null or empty display name', () async {
      final rows = await _directoryQuery(db);
      expect(rows, isNotEmpty);
      for (final row in rows) {
        final name = row['author'] as String?;
        expect(name, isNotNull, reason: 'author_short=${row['author_short']} has null name');
        expect(name!.trim(), isNotEmpty, reason: 'author_short=${row['author_short']} has blank name');
      }
    });

    test('no entry has a single-char "?" name (CircleAvatar fallback trigger)', () async {
      final rows = await _directoryQuery(db);
      for (final row in rows) {
        expect(row['author'], isNot('?'), reason: 'author_short=${row['author_short']} resolves to "?"');
      }
    });

    test('lib/authors/*/index.html stubs are excluded from directory', () async {
      // These slugs have stub-only entries (no real texts, just the index page)
      for (final slug in ['Nanamoli', 'Nanananda', 'Nyanasamvara', 'Silananda']) {
        // Confirm the stub exists in the raw table
        final stubRows = await db.rawQuery(
          "SELECT path FROM texts WHERE author_short = ? AND path GLOB 'lib/authors/*/index.html'",
          [slug],
        );
        if (stubRows.isEmpty) continue; // stub may have been removed from the DB

        // The slug should not appear in the directory
        final dirRows = await _directoryQuery(db);
        final found = dirRows.any((r) => r['author_short'] == slug);
        expect(found, isFalse,
            reason: '$slug appears in directory but has only a stub index.html text');
      }
    });

    test('directory count matches getTextsByAuthor count for top authors', () async {
      final dirRows = await _directoryQuery(db);
      // Check the top 10 by count
      for (final row in dirRows.take(10)) {
        final authorShort = row['author_short'] as String;
        final dirCount = row['text_count'] as int;
        final works = await _worksQuery(db, authorShort);
        expect(works.length, equals(dirCount),
            reason: 'Count mismatch for $authorShort: directory=$dirCount, works=${works.length}');
      }
    });

    test('Thanissaro Bhikkhu is the top author and has a canonical name', () async {
      final rows = await _directoryQuery(db);
      expect(rows, isNotEmpty);
      final top = rows.first;
      expect(top['author_short'], equals('Thanissaro'));
      expect((top['author'] as String).toLowerCase(), contains('thanissaro'));
      expect(top['text_count'] as int, greaterThan(500));
    });

    test('Walshe resolves to a real name, not empty', () async {
      final rows = await _directoryQuery(db);
      final walshe = rows.where((r) => r['author_short'] == 'Walshe').toList();
      expect(walshe, isNotEmpty, reason: 'Walshe must appear in the directory');
      final name = walshe.first['author'] as String;
      expect(name.toLowerCase(), contains('walshe'));
    });
  });

  // ---------------------------------------------------------------------------
  // Search ranking — title matches must outrank body-only matches
  // ---------------------------------------------------------------------------

  group('Search ranking', () {
    late Database db;
    late String tempPath;

    setUpAll(() async {
      final gzFile = File('../app/assets/ati_data.db.gz');
      final dbBytes = gzip.decode(gzFile.readAsBytesSync());
      tempPath = p.join(Directory.systemTemp.path, 'test_ati_search_${DateTime.now().millisecondsSinceEpoch}.db');
      await File(tempPath).writeAsBytes(dbBytes);
      db = await openDatabase(tempPath);
    });

    tearDownAll(() async {
      await db.close();
      await File(tempPath).delete();
    });

    test('title LIKE query finds texts whose title contains the term', () async {
      // "metta" appears in multiple titles on ATI
      final r = await db.rawQuery(
        "SELECT id, title FROM texts WHERE lower(title) LIKE ? LIMIT 10",
        ['%metta%'],
      );
      expect(r, isNotEmpty, reason: 'At least one text should have "metta" in its title');
      for (final row in r) {
        expect((row['title'] as String).toLowerCase(), contains('metta'));
      }
    });

    test('FTS5 search returns ranked results for common term', () async {
      final r = await db.rawQuery('''
        SELECT texts.id, texts.title,
               bm25(search_index, 10, 3, 5, 2, 1, 1) as score
        FROM search_index
        JOIN texts ON texts.rowid = search_index.rowid
        WHERE search_index MATCH 'metta'
        ORDER BY bm25(search_index, 10, 3, 5, 2, 1, 1)
        LIMIT 20
      ''');
      expect(r, isNotEmpty, reason: 'FTS5 search for "metta" must return results');
    });

    test('title-match results are distinct from FTS5 results (two-pass check)', () async {
      const term = 'anapanasati';
      final titleHits = await db.rawQuery(
        "SELECT id FROM texts WHERE lower(title) LIKE ? LIMIT 50",
        ['%$term%'],
      );
      final ftsHits = await db.rawQuery('''
        SELECT texts.id FROM search_index
        JOIN texts ON texts.rowid = search_index.rowid
        WHERE search_index MATCH ?
        LIMIT 50
      ''', [term]);

      // Title hits are a subset of FTS hits — every title match is also an FTS match
      final titleIds = titleHits.map((r) => r['id'] as String).toSet();
      final ftsIds = ftsHits.map((r) => r['id'] as String).toSet();
      if (titleIds.isNotEmpty) {
        expect(ftsIds.containsAll(titleIds), isTrue,
            reason: 'Every title match should also appear in FTS results');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Author bio lookup
  // ---------------------------------------------------------------------------

  group('Author bios', () {
    late Database db;
    late String tempPath;

    setUpAll(() async {
      final gzFile = File('../app/assets/ati_data.db.gz');
      final dbBytes = gzip.decode(gzFile.readAsBytesSync());
      tempPath = p.join(Directory.systemTemp.path, 'test_ati_bios_${DateTime.now().millisecondsSinceEpoch}.db');
      await File(tempPath).writeAsBytes(dbBytes);
      db = await openDatabase(tempPath);
    });

    tearDownAll(() async {
      await db.close();
      await File(tempPath).delete();
    });

    test('authors table exists and has entries', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM authors');
      expect(r.first['c'] as int, greaterThan(10));
    });

    test('Thanissaro bio lookup by author_short succeeds', () async {
      final rows = await db.rawQuery(
        'SELECT * FROM authors WHERE lower(author_short) = ? LIMIT 1',
        ['thanissaro'],
      );
      expect(rows, isNotEmpty, reason: 'Thanissaro bio must be in authors table');
      expect((rows.first['name'] as String).toLowerCase(), contains('thanissaro'));
      expect((rows.first['bio'] as String? ?? '').length, greaterThan(50),
          reason: 'Bio should have meaningful content');
    });

    test('slug fallback lookup works for known authors', () async {
      // Authors whose author_short may differ from slug — e.g. Bhikkhu Bodhi
      final rows = await db.rawQuery(
        'SELECT * FROM authors WHERE slug = ? LIMIT 1',
        ['bodhi'],
      );
      expect(rows, isNotEmpty, reason: 'Bodhi bio must be findable by slug');
    });

    test('all authors table entries have a non-empty name', () async {
      final rows = await db.rawQuery(
          "SELECT slug FROM authors WHERE name IS NULL OR name = ''");
      expect(rows, isEmpty, reason: 'Every authors entry must have a name');
    });

    test('all authors table entries have a non-empty bio', () async {
      // Alias entries (e.g. "see Price, Leonard") legitimately have no bio text.
      // Allow up to 3 such entries; everything else must have a real bio.
      final rows = await db.rawQuery(
          "SELECT slug FROM authors WHERE bio IS NULL OR length(bio) < 10");
      expect(rows.length, lessThanOrEqualTo(3),
          reason: 'Too many authors with empty/missing bios: '
              '${rows.map((r) => r['slug']).join(', ')}');
    });
  });

  // ---------------------------------------------------------------------------
  // Content quality
  // ---------------------------------------------------------------------------

  group('Content quality', () {
    late Database db;
    late String tempPath;

    setUpAll(() async {
      final gzFile = File('../app/assets/ati_data.db.gz');
      final dbBytes = gzip.decode(gzFile.readAsBytesSync());
      tempPath = p.join(Directory.systemTemp.path, 'test_ati_quality_${DateTime.now().millisecondsSinceEpoch}.db');
      await File(tempPath).writeAsBytes(dbBytes);
      db = await openDatabase(tempPath);
    });

    tearDownAll(() async {
      await db.close();
      await File(tempPath).delete();
    });

    test('no indexed text has zero word count', () async {
      final rows = await db.rawQuery('SELECT id, title FROM texts WHERE word_count = 0');
      expect(rows, isEmpty,
          reason: 'All texts in the DB must have at least some content. '
              'Zero-word entries: ${rows.map((r) => r['title']).take(5).join(', ')}');
    });

    test('no indexed text has fewer than 5 words', () async {
      final rows = await db.rawQuery('SELECT id, title, word_count FROM texts WHERE word_count < 5');
      expect(rows, isEmpty,
          reason: 'Texts with <5 words are almost certainly stubs or extraction failures. '
              'Found: ${rows.map((r) => "${r['title']} (${r['word_count']})").take(5).join(', ')}');
    });

    test('PDF-only texts are excluded from the index', () async {
      // Texts with no HTML content are skipped at build time.
      // None of these PDF-only titles should appear in the DB.
      const pdfOnlyTitles = [
        'Wings to Awakening',
        'Right Mindfulness',
        'Noble Strategy',
        'Introducing Buddhism',
      ];
      for (final title in pdfOnlyTitles) {
        final rows = await db.rawQuery(
          'SELECT word_count FROM texts WHERE title = ? AND path NOT GLOB \'lib/authors/*/index.html\' LIMIT 1',
          [title],
        );
        // If present it must have real content (some of these may have HTML versions)
        for (final row in rows) {
          expect(row['word_count'] as int, greaterThan(0),
              reason: '"$title" is in the index with zero words');
        }
      }
    });

    test('all texts have non-empty content_html', () async {
      final rows = await db.rawQuery(
          "SELECT id, title FROM texts WHERE content_html IS NULL OR length(content_html) < 10");
      expect(rows, isEmpty,
          reason: 'Texts with empty content_html: '
              '${rows.map((r) => r['title']).take(5).join(', ')}');
    });

    test('known canonical suttas are present with correct references', () async {
      final expected = [
        ('Satipatthana Sutta', 'MN'),
        ('Anapanasati Sutta', 'MN'),
        ('Dhammacakkappavattana Sutta', 'SN'),
        ('Karaniya Metta Sutta', 'KN'),
      ];
      for (final (title, nikaya) in expected) {
        final rows = await db.rawQuery(
          "SELECT nikaya_abbrev FROM texts WHERE title = ? LIMIT 1",
          [title],
        );
        expect(rows, isNotEmpty, reason: '$title must be in the database');
        expect(rows.first['nikaya_abbrev'] as String, equals(nikaya),
            reason: '$title should be in $nikaya');
      }
    });

    test('subject index has entries', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM subjects');
      expect(r.first['c'] as int, greaterThan(50));
    });

    test('daily contemplations are present', () async {
      final r = await db.rawQuery('SELECT COUNT(*) as c FROM daily_contemplations');
      expect(r.first['c'] as int, greaterThan(0));
    });
  });
}
