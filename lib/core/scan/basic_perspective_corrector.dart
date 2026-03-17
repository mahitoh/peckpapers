import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'perspective_corrector.dart';
import 'scan_models.dart';

class BasicPerspectiveCorrector implements PerspectiveCorrector {
  const BasicPerspectiveCorrector();

  @override
  Future<ScanImage> correct(ScanImage image, PageCorners corners) async {
    final bytes = await File(image.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return image;

    final bounds = _rectFromCorners(corners, decoded.width, decoded.height);
    if (bounds.width < 16 || bounds.height < 16) return image;

    final cropped = img.copyCrop(
      decoded,
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
    );

    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/scan_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final jpg = img.encodeJpg(cropped, quality: 92);
    await File(outputPath).writeAsBytes(jpg, flush: true);

    return ScanImage(
      id: image.id,
      path: outputPath,
      width: cropped.width,
      height: cropped.height,
      source: image.source,
    );
  }

  _Rect _rectFromCorners(PageCorners corners, int width, int height) {
    final minX = [
      corners.topLeft.dx,
      corners.bottomLeft.dx,
      corners.topRight.dx,
      corners.bottomRight.dx,
    ].reduce((a, b) => a < b ? a : b);

    final maxX = [
      corners.topLeft.dx,
      corners.bottomLeft.dx,
      corners.topRight.dx,
      corners.bottomRight.dx,
    ].reduce((a, b) => a > b ? a : b);

    final minY = [
      corners.topLeft.dy,
      corners.bottomLeft.dy,
      corners.topRight.dy,
      corners.bottomRight.dy,
    ].reduce((a, b) => a < b ? a : b);

    final maxY = [
      corners.topLeft.dy,
      corners.bottomLeft.dy,
      corners.topRight.dy,
      corners.bottomRight.dy,
    ].reduce((a, b) => a > b ? a : b);

    final left = minX.floor().clamp(0, width - 1);
    final top = minY.floor().clamp(0, height - 1);
    final right = maxX.ceil().clamp(1, width);
    final bottom = maxY.ceil().clamp(1, height);

    return _Rect(
      left: left,
      top: top,
      width: (right - left).clamp(1, width),
      height: (bottom - top).clamp(1, height),
    );
  }
}

class _Rect {
  const _Rect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final int left;
  final int top;
  final int width;
  final int height;
}
