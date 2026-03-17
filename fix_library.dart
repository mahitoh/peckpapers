import 'dart:io';

void main() {
  final file = File(r'c:\Users\GOLDEN\Desktop\peckpapers\lib\features\liabrary\library_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Remove Document class and _allDocs
  final regExpMockData = RegExp(r'class Document \{.*?\n\];', dotAll: true);
  if (regExpMockData.hasMatch(content)) {
    content = content.replaceFirst(regExpMockData, "import '../../core/services/library_service.dart';");
  } else {
    print("Could not find mock data to replace, trying manual index removal...");
    var lines = file.readAsLinesSync();
    int start = lines.indexWhere((l) => l.startsWith('class Document {'));
    int end = lines.indexWhere((l) => l == '];', start);
    if (start != -1 && end != -1) {
       lines.removeRange(start, end + 1);
       lines.insert(start, "import '../../core/services/library_service.dart';");
       content = lines.join('\n');
    }
  }

  // 2. Add _allDocs list
  content = content.replaceFirst(
    '  List<Document> _filteredDocs = const [];', 
    '  List<Document> _allDocs = [];\n  List<Document> _filteredDocs = [];'
  );

  // 3. Update initState
  content = content.replaceFirst(
    '''    _searchCtrl.addListener(() {
      final next = _searchCtrl.text;
      if (next == _query) return;
      setState(() {
        _query = next;
        _recomputeFiltered();
      });
    });

    _recomputeFiltered();
  }''',
    '''    _searchCtrl.addListener(() {
      final next = _searchCtrl.text;
      if (next == _query) return;
      setState(() {
        _query = next;
        _recomputeFiltered();
      });
    });

    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final docs = await LibraryService.instance.getDocuments();
    if (!mounted) return;
    setState(() {
      _allDocs = docs;
      _recomputeFiltered();
    });
  }'''
  );
  
  // 4. Update Delete
  content = content.replaceFirst(
    '''  void _deleteDoc(Document doc) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"\${doc.title}" removed',
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.amber,
          onPressed: () {},
        ),
      ),
    );
  }''',
    '''  void _deleteDoc(Document doc) async {
    HapticFeedback.mediumImpact();
    await LibraryService.instance.deleteDocument(doc.id);
    _loadDocs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"\${doc.title}" removed',
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.amber,
          onPressed: () async {
            await LibraryService.instance.saveDocument(doc);
            _loadDocs();
          },
        ),
      ),
    );
  }'''
  );

  // 5. Update Fav
  content = content.replaceFirst(
    '''                        onTap: () => widget.onDocumentTap?.call(docs[i]),
                        onDelete: () => _deleteDoc(docs[i]),
                        onFav: () => setState(() {}),
                      ),''',
    '''                        onTap: () => widget.onDocumentTap?.call(docs[i]),
                        onDelete: () => _deleteDoc(docs[i]),
                        onFav: () async {
                          final updated = docs[i].copyWith(isFavourite: !docs[i].isFavourite);
                          await LibraryService.instance.saveDocument(updated);
                          _loadDocs();
                        },
                      ),'''
  );
  
  file.writeAsStringSync(content);
  print('Done applying changes to library_screen.dart');
}
