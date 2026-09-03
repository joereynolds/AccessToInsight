class GlossaryItem {
  final int id;
  final String term;
  final String paliTerm;
  final String definition;
  final String? morePath;

  GlossaryItem({
    required this.id,
    required this.term,
    required this.paliTerm,
    required this.definition,
    this.morePath,
  });

  factory GlossaryItem.fromMap(Map<String, dynamic> map) {
    return GlossaryItem(
      id: map['id'] as int? ?? 0,
      term: map['term'] as String? ?? '',
      paliTerm: map['pali_term'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
      morePath: (map['more_path'] as String?)?.isNotEmpty == true ? map['more_path'] as String : null,
    );
  }
}
