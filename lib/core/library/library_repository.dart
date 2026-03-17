import 'library_models.dart';

abstract class LibraryRepository {
  Future<List<LibraryDocument>> fetchAll();
  Future<void> upsertDocument(LibraryDocument document);
  Future<void> deleteDocument(String id);
  Future<List<LibraryDocument>> search(String query);
}
