import 'dart:io';
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'edge_detection.dart';
import 'scan_models.dart';

class MlKitEdgeDetector implements EdgeDetector {
  const MlKitEdgeDetector();

  @override
  Future<PageCorners?> detectEdges(ScanImage image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(inputImage);
      if (result.blocks.isEmpty) return null;

      final size = await _resolveSize(image);
      final width = size.width;
      final height = size.height;

      double minX = width;
      double minY = height;
      double maxX = 0;
      double maxY = 0;

      for (final block in result.blocks) {
        final rect = block.boundingBox;
        if (rect.left < minX) minX = rect.left;
        if (rect.top < minY) minY = rect.top;
        if (rect.right > maxX) maxX = rect.right;
        if (rect.bottom > maxY) maxY = rect.bottom;
      }

      final marginX = width * 0.04;
      final marginY = height * 0.04;

      minX = (minX - marginX).clamp(0, width);
      minY = (minY - marginY).clamp(0, height);
      maxX = (maxX + marginX).clamp(0, width);
      maxY = (maxY + marginY).clamp(0, height);

      if (maxX - minX < 16 || maxY - minY < 16) return null;

      return PageCorners(
        topLeft: Offset(minX, minY),
        topRight: Offset(maxX, minY),
        bottomRight: Offset(maxX, maxY),
        bottomLeft: Offset(minX, maxY),
      );
    } finally {
      recognizer.close();
    }
  }

  Future<Size> _resolveSize(ScanImage image) async {
    if (image.width > 0 && image.height > 0) {
      return Size(image.width.toDouble(), image.height.toDouble());
    }

    final bytes = await File(image.path).readAsBytes();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }
}
