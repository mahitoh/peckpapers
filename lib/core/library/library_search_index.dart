import 'library_models.dart';

class LibrarySearchIndex {
  final Map<String, Set<String>> _tokenToIds = {};

  void rebuild(List<LibraryDocument> docs) {
    _tokenToIds.clear();
    for (final doc in docs) {
      _indexDocument(doc);
    }
  }

  void addOrUpdate(LibraryDocument doc) {
    remove(doc.id);
    _indexDocument(doc);
  }

  void remove(String id) {
    for (final entry in _tokenToIds.entries) {
      entry.value.remove(id);
    }
  }

  Set<String> search(String query) {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) return {};

    Set<String>? ids;
    for (final token in tokens) {
      final tokenIds = _tokenToIds[token];
      if (tokenIds == null) return {};
      ids = ids == null ? Set.from(tokenIds) : ids.intersection(tokenIds);
      if (ids.isEmpty) return {};
    }
    return ids ?? {};
  }

  void _indexDocument(LibraryDocument doc) {
    final text = [doc.title, doc.subject, doc.textContent ?? ''].join(' ');
    for (final token in _tokenize(text)) {
      _tokenToIds.putIfAbsent(token, () => <String>{}).add(doc.id);
    }
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }
}
