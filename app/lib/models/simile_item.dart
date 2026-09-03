class SimileItem {
  final int id;
  final String simile;
  final String meaning;
  final String suttaRef;
  final String linkPath;

  SimileItem({
    required this.id,
    required this.simile,
    required this.meaning,
    required this.suttaRef,
    required this.linkPath,
  });

  factory SimileItem.fromMap(Map<String, dynamic> map) {
    return SimileItem(
      id: map['id'] as int? ?? 0,
      simile: map['simile'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
      suttaRef: map['sutta_ref'] as String? ?? '',
      linkPath: map['link_path'] as String? ?? '',
    );
  }
}
