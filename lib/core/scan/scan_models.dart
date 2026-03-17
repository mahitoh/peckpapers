import 'dart:ui';

enum ScanSource {
  camera,
  gallery,
  batch,
  pdf,
}

class ScanImage {
  const ScanImage({
    required this.id,
    required this.path,
    required this.width,
    required this.height,
    required this.source,
  });

  final String id;
  final String path;
  final int width;
  final int height;
  final ScanSource source;
}

class PageCorners {
  const PageCorners({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;
}

class ScanPage {
  const ScanPage({
    required this.original,
    required this.corrected,
    required this.text,
    this.corners,
    this.languageHints = const [],
  });

  final ScanImage original;
  final ScanImage corrected;
  final String text;
  final PageCorners? corners;
  final List<String> languageHints;
}

class ScanResult {
  const ScanResult({
    required this.pages,
    required this.fullText,
    this.metadata = const {},
  });

  final List<ScanPage> pages;
  final String fullText;
  final Map<String, Object?> metadata;
}
