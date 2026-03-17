import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class DocumentSummary {
  const DocumentSummary({
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

  factory DocumentSummary.fromJson(Map<String, dynamic> json) {
    return DocumentSummary(
      text: json['text'] as String? ?? '',
      bullets: (json['bullets'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => SummarySection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'] as String)
          : null,
    );
  }
}

class Document {
  const Document({
    required this.id,
    required this.title,
    required this.subject,
    required this.pageCount,
    required this.cardCount,
    required this.progress,
    required this.colorValue,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.dateAdded,
    this.textContent,
    this.isFavourite = false,
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
  final double progress;
  final int colorValue;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String dateAdded;
  final String? textContent;
  final bool isFavourite;
  final DocumentSummary? summary;
  final int easyQuizCount;
  final int mediumQuizCount;
  final int difficultQuizCount;

  int get totalQuizCount => easyQuizCount + mediumQuizCount + difficultQuizCount;
  bool get hasSummary => summary != null && summary!.text.isNotEmpty;
  bool get hasQuizzes => totalQuizCount > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'pageCount': pageCount,
        'cardCount': cardCount,
        'progress': progress,
        'colorValue': colorValue,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'dateAdded': dateAdded,
        'textContent': textContent,
        'isFavourite': isFavourite,
        'summary': summary?.toJson(),
        'easyQuizCount': easyQuizCount,
        'mediumQuizCount': mediumQuizCount,
        'difficultQuizCount': difficultQuizCount,
      };

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      pageCount: json['pageCount'] as int,
      cardCount: json['cardCount'] as int,
      progress: (json['progress'] as num).toDouble(),
      colorValue: json['colorValue'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String?,
      dateAdded: json['dateAdded'] as String,
      textContent: json['textContent'] as String?,
      isFavourite: json['isFavourite'] as bool? ?? false,
      summary: json['summary'] != null
          ? DocumentSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      easyQuizCount: json['easyQuizCount'] as int? ?? 0,
      mediumQuizCount: json['mediumQuizCount'] as int? ?? 0,
      difficultQuizCount: json['difficultQuizCount'] as int? ?? 0,
    );
  }

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);

  Document copyWith({
    String? title,
    String? subject,
    int? pageCount,
    int? cardCount,
    double? progress,
    int? colorValue,
    int? iconCodePoint,
    String? iconFontFamily,
    String? dateAdded,
    String? textContent,
    bool? isFavourite,
    DocumentSummary? summary,
    int? easyQuizCount,
    int? mediumQuizCount,
    int? difficultQuizCount,
  }) {
    return Document(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      pageCount: pageCount ?? this.pageCount,
      cardCount: cardCount ?? this.cardCount,
      progress: progress ?? this.progress,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      dateAdded: dateAdded ?? this.dateAdded,
      textContent: textContent ?? this.textContent,
      isFavourite: isFavourite ?? this.isFavourite,
      summary: summary ?? this.summary,
      easyQuizCount: easyQuizCount ?? this.easyQuizCount,
      mediumQuizCount: mediumQuizCount ?? this.mediumQuizCount,
      difficultQuizCount: difficultQuizCount ?? this.difficultQuizCount,
    );
  }
}

class LibraryService {
  LibraryService._();
  static final LibraryService instance = LibraryService._();

  static const _key = 'library_documents';

  Future<List<Document>> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Document.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDocument(Document doc) async {
    final docs = await getDocuments();
    final index = docs.indexWhere((d) => d.id == doc.id);
    if (index >= 0) {
      docs[index] = doc;
    } else {
      docs.insert(0, doc); // add to top
    }
    await _saveAll(docs);
  }

  Future<void> deleteDocument(String id) async {
    final docs = await getDocuments();
    docs.removeWhere((d) => d.id == id);
    await _saveAll(docs);
  }

  Future<void> _saveAll(List<Document> docs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = docs.map((d) => d.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
