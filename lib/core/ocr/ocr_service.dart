import '../scan/scan_models.dart';

class OcrBlock {
  const OcrBlock({
    required this.text,
    this.confidence,
  });

  final String text;
  final double? confidence;
}

class OcrResult {
  const OcrResult({
    required this.text,
    this.blocks = const [],
  });

  final String text;
  final List<OcrBlock> blocks;
}

abstract class OcrService {
  Future<OcrResult> recognize(
    ScanImage image, {
    List<String> languageHints = const [],
  });
}
