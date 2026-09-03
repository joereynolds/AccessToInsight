import 'dart:convert';

class TextItem {
  final int rowid;
  final String id;
  final String path;
  final String title;
  final String? subtitle;
  final String? suttaRef;
  final String nikaya;
  final String nikayaAbbrev;
  final String collection;
  final String author;
  final String authorShort;
  final String? ptsId;
  final String type;
  final String summary;
  final String contentHtml;
  final String contentPlain;
  final Map<String, String> footnotes;
  final int wordCount;
  final String? year;
  final String? license;

  TextItem({
    required this.rowid,
    required this.id,
    required this.path,
    required this.title,
    this.subtitle,
    this.suttaRef,
    required this.nikaya,
    required this.nikayaAbbrev,
    required this.collection,
    required this.author,
    required this.authorShort,
    this.ptsId,
    required this.type,
    required this.summary,
    required this.contentHtml,
    required this.contentPlain,
    required this.footnotes,
    required this.wordCount,
    this.year,
    this.license,
  });

  int get readingTimeMinutes => (wordCount / 180).ceil().clamp(1, 999);

  String get displayReference {
    if (suttaRef != null && suttaRef!.trim().isNotEmpty) {
      return suttaRef!;
    }
    if (ptsId != null && ptsId!.trim().isNotEmpty) {
      return ptsId!;
    }
    return nikayaAbbrev;
  }

  factory TextItem.fromMap(Map<String, dynamic> map) {
    Map<String, String> parsedNotes = {};
    if (map['footnotes_json'] != null && map['footnotes_json'].toString().isNotEmpty) {
      try {
        final decoded = json.decode(map['footnotes_json']);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            parsedNotes[k.toString()] = v.toString();
          });
        }
      } catch (_) {}
    }

    return TextItem(
      rowid: map['rowid'] as int? ?? 0,
      id: map['id'] as String? ?? '',
      path: map['path'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled',
      subtitle: map['subtitle'] as String?,
      suttaRef: map['sutta_ref'] as String?,
      nikaya: map['nikaya'] as String? ?? '',
      nikayaAbbrev: map['nikaya_abbrev'] as String? ?? '',
      collection: map['collection'] as String? ?? '',
      author: map['author'] as String? ?? '',
      authorShort: map['author_short'] as String? ?? '',
      ptsId: map['pts_id'] as String?,
      type: map['type'] as String? ?? 'sutta',
      summary: map['summary'] as String? ?? '',
      contentHtml: map['content_html'] as String? ?? '',
      contentPlain: map['content_plain'] as String? ?? '',
      footnotes: parsedNotes,
      wordCount: map['word_count'] as int? ?? 0,
      year: map['year'] as String?,
      license: map['license'] as String?,
    );
  }
}
