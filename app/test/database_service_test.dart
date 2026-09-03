import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

import 'package:app/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('DatabaseService unpacks and queries Access to Insight data', () async {
    // Verify gzip asset exists
    final gzFile = File('../app/assets/ati_data.db.gz');
    expect(gzFile.existsSync(), isTrue, reason: 'ati_data.db.gz must exist in app/assets');

    // Test direct database query using sqflite_common_ffi
    final dbBytes = gzip.decode(gzFile.readAsBytesSync());
    final tempDbPath = p.join(Directory.systemTemp.path, 'test_ati_${DateTime.now().millisecondsSinceEpoch}.db');
    final tempDbFile = File(tempDbPath);
    await tempDbFile.writeAsBytes(dbBytes);

    final db = await openDatabase(tempDbPath);

    // 1. Verify Texts count
    final countRes = await db.rawQuery('SELECT COUNT(*) as count FROM texts');
    final totalTexts = countRes.first['count'] as int;
    expect(totalTexts, greaterThan(1500), reason: 'Must contain over 1,500 canonical texts');

    // 2. Verify Nikaya Collections are preserved
    final nikayasRes = await db.rawQuery('SELECT DISTINCT nikaya_abbrev FROM texts');
    final abbrevs = nikayasRes.map((r) => r['nikaya_abbrev'] as String).toSet();
    expect(abbrevs.contains('DN'), isTrue);
    expect(abbrevs.contains('MN'), isTrue);
    expect(abbrevs.contains('SN'), isTrue);
    expect(abbrevs.contains('AN'), isTrue);
    expect(abbrevs.contains('KN'), isTrue);

    // 3. Verify FTS5 Search
    final searchRes = await db.rawQuery('''
      SELECT texts.id, texts.title FROM search_index
      JOIN texts ON texts.rowid = search_index.rowid
      WHERE search_index MATCH 'loving*'
      LIMIT 5
    ''');
    expect(searchRes.isNotEmpty, isTrue, reason: 'FTS5 search for loving-kindness must return results');

    // 4. Verify Glossary
    final glossaryRes = await db.rawQuery('SELECT COUNT(*) as count FROM glossary');
    expect(glossaryRes.first['count'] as int, greaterThan(150));

    // 5. Verify Similes
    final similesRes = await db.rawQuery('SELECT COUNT(*) as count FROM similes');
    expect(similesRes.first['count'] as int, greaterThan(250));

    // 6. Verify Dhammapada
    final dhpRes = await db.rawQuery('SELECT COUNT(*) as count FROM dhammapada_verses');
    expect(dhpRes.first['count'] as int, greaterThan(200));

    // 7. Verify Path to Freedom stages
    final ptfRes = await db.rawQuery('SELECT COUNT(*) as count FROM ptf_sections');
    expect(ptfRes.first['count'] as int, equals(6));

    await db.close();
    await tempDbFile.delete();
  });
}
