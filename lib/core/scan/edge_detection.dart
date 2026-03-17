import 'scan_models.dart';

abstract class EdgeDetector {
  Future<PageCorners?> detectEdges(ScanImage image);
}
