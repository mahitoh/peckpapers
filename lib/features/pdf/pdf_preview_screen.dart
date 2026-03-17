// lib/features/pdf/pdf_preview_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.bullets = const [],
    this.footer,
  });

  final String title;
  final String? subtitle;
  final String body;
  final List<String> bullets;
  final String? footer;

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  subtitle!,
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
                body,
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 3),
              ),
              if (bullets.isNotEmpty) ...[
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
                  children: bullets
                      .map(
                        (b) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('  ', style: const pw.TextStyle(fontSize: 12)),
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
              if (footer != null) ...[
                pw.Spacer(),
                pw.Container(height: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 8),
                pw.Text(
                  footer!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('PDF Preview', style: AppTextStyles.headingLG),
      ),
      body: PdfPreview(
        build: _buildPdf,
        pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}



