import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../scan/scan_models.dart';
import 'ocr_service.dart';

class MlKitOcrService implements OcrService {
  const MlKitOcrService();

  @override
  Future<OcrResult> recognize(
    ScanImage image, {
    List<String> languageHints = const [],
  }) async {
    final script = _scriptForHints(languageHints);
    final recognizer = TextRecognizer(script: script);
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final result = await recognizer.processImage(inputImage);

      final blocks = result.blocks
          .map((block) => OcrBlock(text: block.text))
          .toList();

      return OcrResult(text: result.text, blocks: blocks);
    } finally {
      recognizer.close();
    }
  }

  TextRecognitionScript _scriptForHints(List<String> hints) {
    if (hints.isEmpty) return TextRecognitionScript.latin;

    final normalized = hints.map((h) => h.toLowerCase()).toList();
    if (_containsAny(normalized, const ['zh', 'chinese', 'han'])) {
      return TextRecognitionScript.chinese;
    }
    if (_containsAny(normalized, const ['ja', 'japanese'])) {
      return TextRecognitionScript.japanese;
    }
    if (_containsAny(normalized, const ['ko', 'korean'])) {
      return TextRecognitionScript.korean;
    }
    if (_containsAny(normalized, const ['hi', 'hindi', 'devanagari'])) {
      return TextRecognitionScript.latin; // Fallback: devanagari not found in this package version.
    }
    return TextRecognitionScript.latin;
  }

  bool _containsAny(List<String> items, List<String> needles) {
    for (final needle in needles) {
      if (items.any((item) => item.contains(needle))) return true;
    }
    return false;
  }
}
