class PtfSection {
  final int id;
  final int stepOrder;
  final String code;
  final String title;
  final String paliName;
  final String summary;
  final String detailPath;

  PtfSection({
    required this.id,
    required this.stepOrder,
    required this.code,
    required this.title,
    required this.paliName,
    required this.summary,
    required this.detailPath,
  });

  factory PtfSection.fromMap(Map<String, dynamic> map) {
    return PtfSection(
      id: map['id'] as int? ?? 0,
      stepOrder: map['step_order'] as int? ?? 0,
      code: map['code'] as String? ?? '',
      title: map['title'] as String? ?? '',
      paliName: map['pali_name'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      detailPath: map['detail_path'] as String? ?? '',
    );
  }
}
