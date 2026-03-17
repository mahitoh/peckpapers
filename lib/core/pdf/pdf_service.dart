import 'pdf_models.dart';

abstract class PdfService {
  Future<List<int>> buildPdf(PdfDocumentPayload payload);
}
