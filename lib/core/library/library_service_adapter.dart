import 'package:flutter/material.dart';
import '../services/library_service.dart' as legacy;
import 'library_models.dart';
import 'library_repository.dart';

class LibraryServiceAdapter implements LibraryRepository {
  LibraryServiceAdapter({legacy.LibraryService? service})
      : _service = service ?? legacy.LibraryService.instance;

  final legacy.LibraryService _service;

  @override
  Future<List<LibraryDocument>> fetchAll() async {
    final docs = await _service.getDocuments();
    return docs.map(_fromLegacy).toList();
  }

  @override
  Future<void> upsertDocument(LibraryDocument document) async {
    final legacyDoc = _toLegacy(document);
    await _service.saveDocument(legacyDoc);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _service.deleteDocument(id);
  }

  @override
  Future<List<LibraryDocument>> search(String query) async {
    final docs = await fetchAll();
    if (query.trim().isEmpty) return docs;
    final q = query.toLowerCase();
    return docs
        .where((doc) =>
            doc.title.toLowerCase().contains(q) ||
            doc.subject.toLowerCase().contains(q) ||
            (doc.textContent ?? '').toLowerCase().contains(q))
        .toList();
  }

  LibraryDocument _fromLegacy(legacy.Document doc) {
    return LibraryDocument(
      id: doc.id,
      title: doc.title,
      subject: doc.subject,
      pageCount: doc.pageCount,
      cardCount: doc.cardCount,
      createdAt: DateTime.tryParse(doc.dateAdded) ?? DateTime.now(),
      isFavorite: doc.isFavourite,
      textContent: doc.textContent,
      summary: doc.summary != null
          ? LibrarySummary(
              text: doc.summary!.text,
              bullets: doc.summary!.bullets,
              generatedAt: doc.summary!.generatedAt,
            )
          : null,
      easyQuizCount: doc.easyQuizCount,
      mediumQuizCount: doc.mediumQuizCount,
      difficultQuizCount: doc.difficultQuizCount,
    );
  }

  legacy.Document _toLegacy(LibraryDocument doc) {
    return legacy.Document(
      id: doc.id,
      title: doc.title,
      subject: doc.subject,
      pageCount: doc.pageCount,
      cardCount: doc.cardCount,
      progress: 0.0,
      colorValue: Colors.amber.toARGB32(),
      iconCodePoint: Icons.picture_as_pdf_rounded.codePoint,
      iconFontFamily: Icons.picture_as_pdf_rounded.fontFamily,
      dateAdded: doc.createdAt.toIso8601String(),
      textContent: doc.textContent,
      isFavourite: doc.isFavorite,
      summary: doc.summary != null
          ? legacy.DocumentSummary(
              text: doc.summary!.text,
              bullets: doc.summary!.bullets,
              generatedAt: doc.summary!.generatedAt,
            )
          : null,
      easyQuizCount: doc.easyQuizCount,
      mediumQuizCount: doc.mediumQuizCount,
      difficultQuizCount: doc.difficultQuizCount,
    );
  }
}
