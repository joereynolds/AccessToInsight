import 'package:flutter_test/flutter_test.dart';
import 'package:app/utils.dart';

void main() {
  group('stripHtml', () {
    test('removes simple tags', () {
      expect(stripHtml('<b>bold</b>'), 'bold');
      expect(stripHtml('<i>italic</i>'), 'italic');
      expect(stripHtml('<p>paragraph</p>'), 'paragraph');
    });

    test('removes tags with attributes', () {
      expect(stripHtml('<b class="x">text</b>'), 'text');
      expect(stripHtml('<span style="color:red">text</span>'), 'text');
    });

    test('removes nested tags', () {
      expect(stripHtml('<p><i>sila</i> and <i>samadhi</i></p>'), 'sila and samadhi');
    });

    test('decodes &amp;', () => expect(stripHtml('AT&amp;T'), 'AT&T'));
    test('decodes &lt; &gt;', () => expect(stripHtml('&lt;tag&gt;'), '<tag>'));
    test('decodes &quot;', () => expect(stripHtml('&quot;quoted&quot;'), '"quoted"'));
    test('decodes &#39;', () => expect(stripHtml('it&#39;s'), "it's"));
    test('decodes &nbsp;', () => expect(stripHtml('a&nbsp;b'), 'a b'));

    test('strips tags then decodes entities', () {
      expect(stripHtml('<i>Pa&#39;li</i> &amp; Pali'), "Pa'li & Pali");
    });

    test('trims surrounding whitespace', () {
      expect(stripHtml('  hello  '), 'hello');
      expect(stripHtml('  <p>hello</p>  '), 'hello');
    });

    test('returns empty string unchanged', () {
      expect(stripHtml(''), '');
    });

    test('passes through plain text unchanged', () {
      expect(stripHtml('no tags here'), 'no tags here');
    });

    test('handles Pali diacritics in tags (real sutta subtitle case)', () {
      expect(stripHtml('<i>Sila</i>, <i>Samadhi</i> &amp; <i>Panna</i>'),
          'Sila, Samadhi & Panna');
    });
  });
}
