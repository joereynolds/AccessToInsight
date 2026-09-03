class DhpVerse {
  final int id;
  final int chapterNum;
  final String chapterTitle;
  final int verseNum;
  final String verseText;
  final String translator;

  DhpVerse({
    required this.id,
    required this.chapterNum,
    required this.chapterTitle,
    required this.verseNum,
    required this.verseText,
    required this.translator,
  });

  factory DhpVerse.fromMap(Map<String, dynamic> map) {
    return DhpVerse(
      id: map['id'] as int? ?? 0,
      chapterNum: map['chapter_num'] as int? ?? 0,
      chapterTitle: map['chapter_title'] as String? ?? '',
      verseNum: map['verse_num'] as int? ?? 0,
      verseText: map['verse_text'] as String? ?? '',
      translator: map['translator'] as String? ?? '',
    );
  }
}
