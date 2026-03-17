// lib/features/pdf/pdf_preview_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_button.dart';
import '../../core/pdf/peck_pdf_service.dart';
import '../../core/pdf/pdf_models.dart';
import '../../core/scan/scan_models.dart';
import '../../core/ai/offline_ai_service.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.bullets = const [],
    this.footer,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.scanResult,
  });

  final String title;
  final String? subtitle;
  final String body;
  final List<String> bullets;
  final String? footer;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final ScanResult? scanResult;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late String _body;
  late List<String> _bullets;
  bool _regenerating = false;

  @override
  void initState() {
    super.initState();
    _body = widget.body;
    _bullets = widget.bullets;
  }

  Future<void> _regenerateSummary() async {
    if (widget.scanResult == null) return;
    setState(() => _regenerating = true);
    try {
      final summary = await OfflineAiService.instance.summarize(
        widget.scanResult!.fullText,
        maxBullets: 6,
      );
      setState(() {
        _body = summary.summary;
        _bullets = summary.bullets;
        _regenerating = false;
      });
    } catch (e) {
      setState(() => _regenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to regenerate summary: $e')),
        );
      }
    }
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final payload = PdfDocumentPayload(
      id: 'preview_${DateTime.now().microsecondsSinceEpoch}',
      title: widget.title,
      subtitle: widget.subtitle,
      body: _body,
      bullets: _bullets,
      footer: widget.footer,
      createdAt: DateTime.now(),
      subject: widget.subtitle,
      sourceText: _body,
    );

    final bytes = await const PeckPdfService().buildPdf(payload);
    return Uint8List.fromList(bytes);
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
        pdfFileName: '${widget.title.replaceAll(' ', '_')}.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Row(
            children: [
              Expanded(
                child: PeckButton(
                  label: 'Save to Library',
                  onPressed: widget.onPrimaryAction,
                  variant: PeckButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PeckButton(
                  label: _regenerating ? 'Regenerating...' : 'Regenerate Summary',
                  onPressed: _regenerating ? null : _regenerateSummary,
                  variant: PeckButtonVariant.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

