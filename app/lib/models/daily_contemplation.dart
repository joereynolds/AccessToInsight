class DailyContemplation {
  final int id;
  final int dayOfYear;
  final String title;
  final String versePali;
  final String verseEnglish;
  final String sourceRef;
  final String theme;
  final String reflectionPrompt;

  DailyContemplation({
    required this.id,
    required this.dayOfYear,
    required this.title,
    required this.versePali,
    required this.verseEnglish,
    required this.sourceRef,
    required this.theme,
    required this.reflectionPrompt,
  });

  factory DailyContemplation.fromMap(Map<String, dynamic> map) {
    return DailyContemplation(
      id: map['id'] as int? ?? 0,
      dayOfYear: map['day_of_year'] as int? ?? 1,
      title: map['title'] as String? ?? 'Daily Contemplation',
      versePali: map['verse_pali'] as String? ?? '',
      verseEnglish: map['verse_english'] as String? ?? '',
      sourceRef: map['source_ref'] as String? ?? '',
      theme: map['theme'] as String? ?? 'Wisdom',
      reflectionPrompt: map['reflection_prompt'] as String? ?? '',
    );
  }
}
