class PdfDocumentPayload {
  const PdfDocumentPayload({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.subtitle,
    this.bullets = const [],
    this.footer,
    this.subject,
    this.sourceText,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? subtitle;
  final List<String> bullets;
  final String? footer;
  final String? subject;
  final String? sourceText;
}
