import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_models.dart';
import 'pdf_service.dart';

class PeckPdfService implements PdfService {
  const PeckPdfService();

  @override
  Future<List<int>> buildPdf(PdfDocumentPayload payload) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                payload.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (payload.subtitle != null) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  payload.subtitle!,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
              pw.SizedBox(height: 16),
              pw.Container(height: 2, color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Text(
                payload.body,
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 3),
              ),
              if (payload.bullets.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  'Highlights',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Column(
                  children: payload.bullets
                      .map(
                        (b) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('•  ', style: const pw.TextStyle(fontSize: 12)),
                              pw.Expanded(
                                child: pw.Text(
                                  b,
                                  style: const pw.TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (payload.footer != null) ...[
                pw.Spacer(),
                pw.Container(height: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Text(
                  payload.footer!,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
