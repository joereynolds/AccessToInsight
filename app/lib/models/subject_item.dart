class SubjectItem {
  final int id;
  final String subject;
  final String details;

  SubjectItem({
    required this.id,
    required this.subject,
    required this.details,
  });

  factory SubjectItem.fromMap(Map<String, dynamic> map) {
    return SubjectItem(
      id: map['id'] as int? ?? 0,
      subject: map['subject'] as String? ?? '',
      details: map['details'] as String? ?? '',
    );
  }
}
