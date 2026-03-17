class SummarySection {
  const SummarySection({
    required this.topic,
    required this.content,
    this.bullets = const [],
  });

  final String topic;
  final String content;
  final List<String> bullets;

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'content': content,
        'bullets': bullets,
      };

  factory SummarySection.fromJson(Map<String, dynamic> json) => SummarySection(
        topic: json['topic'] as String,
        content: json['content'] as String,
        bullets: (json['bullets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );
}

class LibrarySummary {
  const LibrarySummary({
    required this.text,
    this.bullets = const [],
    this.sections = const [],
    this.generatedAt,
  });

  final String text;
  final List<String> bullets;
  final List<SummarySection> sections;
  final DateTime? generatedAt;

  Map<String, dynamic> toJson() => {
        'text': text,
        'bullets': bullets,
        'sections': sections.map((s) => s.toJson()).toList(),
        'generatedAt': generatedAt?.toIso8601String(),
      };

  factory LibrarySummary.fromJson(Map<String, dynamic> json) => LibrarySummary(
        text: json['text'] as String,
        bullets: (json['bullets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        sections: (json['sections'] as List<dynamic>?)
                ?.map((e) => SummarySection.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        generatedAt: json['generatedAt'] != null ? DateTime.parse(json['generatedAt'] as String) : null,
      );
}

class LibraryDocument {
  const LibraryDocument({
    required this.id,
    required this.title,
    required this.subject,
    required this.pageCount,
    required this.cardCount,
    required this.createdAt,
    this.pdfPath,
    this.textContent,
    this.isFavorite = false,
    this.summary,
    this.easyQuizCount = 0,
    this.mediumQuizCount = 0,
    this.difficultQuizCount = 0,
  });

  final String id;
  final String title;
  final String subject;
  final int pageCount;
  final int cardCount;
  final DateTime createdAt;
  final String? pdfPath;
  final String? textContent;
  final bool isFavorite;
  final LibrarySummary? summary;
  final int easyQuizCount;
  final int mediumQuizCount;
  final int difficultQuizCount;

  int get totalQuizCount => easyQuizCount + mediumQuizCount + difficultQuizCount;
  bool get hasSummary => summary != null && summary!.text.isNotEmpty;
  bool get hasQuizzes => totalQuizCount > 0;

  LibraryDocument copyWith({
    String? title,
    String? subject,
    int? pageCount,
    int? cardCount,
    DateTime? createdAt,
    String? pdfPath,
    String? textContent,
    bool? isFavorite,
    LibrarySummary? summary,
    int? easyQuizCount,
    int? mediumQuizCount,
    int? difficultQuizCount,
  }) {
    return LibraryDocument(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      pageCount: pageCount ?? this.pageCount,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      pdfPath: pdfPath ?? this.pdfPath,
      textContent: textContent ?? this.textContent,
      isFavorite: isFavorite ?? this.isFavorite,
      summary: summary ?? this.summary,
      easyQuizCount: easyQuizCount ?? this.easyQuizCount,
      mediumQuizCount: mediumQuizCount ?? this.mediumQuizCount,
      difficultQuizCount: difficultQuizCount ?? this.difficultQuizCount,
    );
  }
}

class LibraryFolder {
  const LibraryFolder({
    required this.id,
    required this.name,
    required this.documentIds,
  });

  final String id;
  final String name;
  final List<String> documentIds;
}
