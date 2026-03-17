import 'scan_models.dart';

abstract class PerspectiveCorrector {
  Future<ScanImage> correct(ScanImage image, PageCorners corners);
}
