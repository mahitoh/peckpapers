import '../ocr/ocr_service.dart';
import 'edge_detection.dart';
import 'perspective_corrector.dart';
import 'scan_models.dart';

class ScanPipeline {
  const ScanPipeline({
    required EdgeDetector edgeDetector,
    required PerspectiveCorrector perspectiveCorrector,
    required OcrService ocrService,
  })  : _edgeDetector = edgeDetector,
        _perspectiveCorrector = perspectiveCorrector,
        _ocrService = ocrService;

  final EdgeDetector _edgeDetector;
  final PerspectiveCorrector _perspectiveCorrector;
  final OcrService _ocrService;

  Future<ScanResult> process(
    List<ScanImage> images, {
    List<String> languageHints = const [],
  }) async {
    final pages = <ScanPage>[];
    final fullTextBuffer = StringBuffer();

    for (final image in images) {
      final corners = await _edgeDetector.detectEdges(image);
      final corrected = corners == null
          ? image
          : await _perspectiveCorrector.correct(image, corners);

      final ocr = await _ocrService.recognize(
        corrected,
        languageHints: languageHints,
      );

      pages.add(
        ScanPage(
          original: image,
          corrected: corrected,
          text: ocr.text,
          corners: corners,
          languageHints: languageHints,
        ),
      );

      if (ocr.text.trim().isNotEmpty) {
        fullTextBuffer.writeln(ocr.text.trim());
      }
    }

    return ScanResult(
      pages: pages,
      fullText: fullTextBuffer.toString().trim(),
      metadata: {
        'pageCount': pages.length,
      },
    );
  }
}
