import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/text_item.dart';

TextItem _make({
  int wordCount = 0,
  String? suttaRef,
  String? ptsId,
  String nikayaAbbrev = 'SN',
  String author = '',
  String authorShort = '',
  String title = 'Test',
  String id = 'test-id',
  String path = 'test/path.html',
  String contentHtml = '',
}) {
  return TextItem(
    rowid: 1,
    id: id,
    path: path,
    title: title,
    nikaya: 'Samyutta Nikaya',
    nikayaAbbrev: nikayaAbbrev,
    collection: '',
    author: author,
    authorShort: authorShort,
    type: 'sutta',
    summary: '',
    contentHtml: contentHtml,
    contentPlain: '',
    footnotes: {},
    wordCount: wordCount,
    suttaRef: suttaRef,
    ptsId: ptsId,
  );
}

void main() {
  group('TextItem.fromMap', () {
    test('parses all standard fields', () {
      final item = TextItem.fromMap({
        'rowid': 42,
        'id': 'sn/sn22.059.nymo.html',
        'path': 'tipitaka/sn/sn22/sn22.059.nymo.html',
        'title': 'Anattalakkhaṇa Sutta',
        'subtitle': 'The Discourse on the Not-self Characteristic',
        'sutta_ref': 'SN 22.59',
        'nikaya': 'Samyutta Nikaya',
        'nikaya_abbrev': 'SN',
        'collection': 'sn',
        'author': 'Ñanamoli Thera',
        'author_short': 'Ñanamoli',
        'pts_id': 'PTS:1',
        'type': 'sutta',
        'summary': 'The classic discourse on non-self.',
        'content_html': '<p>Body text</p>',
        'content_plain': 'Body text',
        'footnotes_json': '{"1": "A footnote"}',
        'word_count': 500,
        'year': '1993',
        'license': 'ATI',
      });
      expect(item.rowid, 42);
      expect(item.id, 'sn/sn22.059.nymo.html');
      expect(item.title, 'Anattalakkhaṇa Sutta');
      expect(item.subtitle, 'The Discourse on the Not-self Characteristic');
      expect(item.suttaRef, 'SN 22.59');
      expect(item.nikayaAbbrev, 'SN');
      expect(item.author, 'Ñanamoli Thera');
      expect(item.authorShort, 'Ñanamoli');
      expect(item.wordCount, 500);
      expect(item.footnotes['1'], 'A footnote');
      expect(item.year, '1993');
    });

    test('handles all-null optional fields gracefully', () {
      final item = TextItem.fromMap({
        'rowid': 1,
        'id': 'test',
        'path': 'test.html',
        'title': null,
        'subtitle': null,
        'sutta_ref': null,
        'nikaya': null,
        'nikaya_abbrev': null,
        'collection': null,
        'author': null,
        'author_short': null,
        'pts_id': null,
        'type': null,
        'summary': null,
        'content_html': null,
        'content_plain': null,
        'footnotes_json': null,
        'word_count': null,
        'year': null,
        'license': null,
      });
      expect(item.title, 'Untitled');
      expect(item.subtitle, isNull);
      expect(item.author, '');
      expect(item.authorShort, '');
      expect(item.wordCount, 0);
      expect(item.footnotes, isEmpty);
      expect(item.readingTimeMinutes, 1); // clamp to minimum
    });

    test('handles malformed footnotes_json without throwing', () {
      final item = TextItem.fromMap({
        'rowid': 1, 'id': 'x', 'path': 'x.html', 'title': 'X',
        'nikaya': '', 'nikaya_abbrev': '', 'collection': '',
        'author': '', 'author_short': '', 'type': 'sutta',
        'summary': '', 'content_html': '', 'content_plain': '',
        'word_count': 0,
        'footnotes_json': '{not valid json!!!}',
      });
      expect(item.footnotes, isEmpty);
    });
  });

  group('TextItem.readingTimeMinutes', () {
    test('0 words returns minimum of 1', () => expect(_make(wordCount: 0).readingTimeMinutes, 1));
    test('1 word returns 1', () => expect(_make(wordCount: 1).readingTimeMinutes, 1));
    test('180 words returns 1', () => expect(_make(wordCount: 180).readingTimeMinutes, 1));
    test('181 words rounds up to 2', () => expect(_make(wordCount: 181).readingTimeMinutes, 2));
    test('360 words returns 2', () => expect(_make(wordCount: 360).readingTimeMinutes, 2));
    test('900 words returns 5', () => expect(_make(wordCount: 900).readingTimeMinutes, 5));
    test('901 words rounds up to 6', () => expect(_make(wordCount: 901).readingTimeMinutes, 6));
  });

  group('TextItem.displayReference', () {
    test('prefers suttaRef when present', () {
      expect(_make(suttaRef: 'SN 1.1', ptsId: 'PTS:1', nikayaAbbrev: 'SN').displayReference, 'SN 1.1');
    });

    test('falls back to ptsId when suttaRef is absent', () {
      expect(_make(suttaRef: null, ptsId: 'PTS:1', nikayaAbbrev: 'SN').displayReference, 'PTS:1');
    });

    test('falls back to nikayaAbbrev when both absent', () {
      expect(_make(suttaRef: null, ptsId: null, nikayaAbbrev: 'AN').displayReference, 'AN');
    });

    test('ignores blank suttaRef and uses ptsId', () {
      expect(_make(suttaRef: '   ', ptsId: 'PTS:1', nikayaAbbrev: 'SN').displayReference, 'PTS:1');
    });

    test('ignores blank ptsId and uses nikayaAbbrev', () {
      expect(_make(suttaRef: null, ptsId: '  ', nikayaAbbrev: 'MN').displayReference, 'MN');
    });
  });
}
