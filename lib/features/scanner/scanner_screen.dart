// lib/features/scanner/scanner_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_button.dart';
import '../../core/widgets/glass_card.dart';
import '../pdf/pdf_preview_screen.dart';

// --- Scanner states ---

enum _ScanState {
  idle, // Camera live, waiting for capture
  scanning, // Processing OCR - progress bar animating
  done, // Text extracted - show save sheet
  error, // Something went wrong
}

// --- Screen ---

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, this.onSaved, this.onBack});

  final VoidCallback? onSaved;
  final VoidCallback? onBack;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  CameraController? _camCtrl;
  bool _camReady = false;
  final _picker = ImagePicker();
  XFile? _pickedImage;

  _ScanState _state = _ScanState.idle;
  double _progress = 0.0;
  String _extractedText = '';

  // Scan line animation  bounces top  bottom inside the frame
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLineAnim;

  // Progress animation
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  // Capture button pulse
  late AnimationController _btnPulseCtrl;
  late Animation<double> _btnPulseAnim;

  // Corner brackets entrance
  late AnimationController _bracketsCtrl;
  late Animation<double> _bracketsFade;
  late Animation<double> _bracketsScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCamera();
  }

  void _initAnimations() {
    //  Scan line bounce 
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _scanLineAnim = CurvedAnimation(
      parent: _scanLineCtrl,
      curve: Curves.easeInOut,
    );

    //  Progress bar 
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOutCubic),
    );
    _progressCtrl.addListener(() {
      setState(() => _progress = _progressAnim.value);
    });
    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onScanComplete();
      }
    });

    //  Capture button pulse 
    _btnPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _btnPulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _btnPulseCtrl, curve: Curves.easeInOut));

    //  Bracket entrance 
    _bracketsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bracketsFade = CurvedAnimation(
      parent: _bracketsCtrl,
      curve: Curves.easeOut,
    );
    _bracketsScale = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(parent: _bracketsCtrl, curve: Curves.easeOutBack),
    );
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _camCtrl = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _camCtrl!.initialize();
      if (!mounted) return;

      setState(() => _camReady = true);
      _bracketsCtrl.forward();
    } catch (_) {
      setState(() => _state = _ScanState.error);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_state == _ScanState.scanning) return;
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _pickedImage = image;
      _state = _ScanState.idle;
    });
    // Immediately process scan after picking an image
    _captureAndScan();
  }

  Future<void> _captureAndScan() async {
    if (_state != _ScanState.idle) return;
    if (!_camReady && _pickedImage == null) return;

    setState(() {
      _state = _ScanState.scanning;
      _progress = 0.0;
    });

    // Simulate OCR processing  replace with real ML Kit call
    _progressCtrl.forward(from: 0);
  }

  void _onScanComplete() {
    // Simulate extracted text  replace with real OCR result
    setState(() {
      _extractedText =
          'Sample extracted text from your notes. '
          'Integration by parts: u dv = uv  v du. '
          'Remember to check boundary conditions.';
      _state = _ScanState.done;
    });
    _showSaveSheet();
  }

  void _openPdfPreview({required String title, required String subject}) {
    final safeTitle = title.trim().isEmpty ? 'Untitled Scan' : title.trim();
    final safeSubject = subject.trim().isEmpty ? 'General' : subject.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          title: safeTitle,
          subtitle: safeSubject,
          body: _extractedText,
          bullets: [
            'Source: camera scan (local only)',
            'Words extracted: ${_extractedText.split(' ').length}',
          ],
          footer: 'Generated by PeckPapers (local device)',
        ),
      ),
    );
  }

  void _reset() {
    _progressCtrl.reset();
    setState(() {
      _state = _ScanState.idle;
      _progress = 0.0;
      _pickedImage = null;
    });
  }

  void _showSaveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaveSheet(
        extractedText: _extractedText,
        onSave: (title, subject) {
          Navigator.pop(context);
          _openPdfPreview(title: title, subject: subject);
          widget.onSaved?.call();
        },
        onDiscard: () {
          Navigator.pop(context);
          _reset();
        },
      ),
    );
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    _scanLineCtrl.dispose();
    _progressCtrl.dispose();
    _btnPulseCtrl.dispose();
    _bracketsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Frame dimensions  golden ratio-ish viewport
    final frameW = size.width * 0.82;
    final frameH = frameW * 1.28;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          //  Camera preview / placeholder 
          if (_pickedImage != null)
            Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
          else if (_camReady)
            CameraPreview(_camCtrl!)
          else
            Container(color: const Color(0xFF0A0A0A)),

          // Soft overlay to align with app tone
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacityCompat(0.35),
                      Colors.black.withOpacityCompat(0.75),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //  Dark vignette overlay (outside frame) 
          _FrameVignette(frameW: frameW, frameH: frameH, size: size),

          //  Scan frame with brackets 
          Center(
            child: FadeTransition(
              opacity: _bracketsFade,
              child: ScaleTransition(
                scale: _bracketsScale,
                child: _ScanFrame(
                  width: frameW,
                  height: frameH,
                  scanLineAnim: _scanLineAnim,
                  isScanning: _state == _ScanState.scanning,
                  progress: _progress,
                ),
              ),
            ),
          ),

          //  Top bar 
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _TopBar(
                onBack: widget.onBack ?? () => Navigator.pop(context),
              ),
            ),
          ),

          //  Title prompt 
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 0,
            right: 0,
            child: _TitlePrompt(state: _state, progress: _progress),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 122,
            left: 24,
            right: 24,
            child: _ScanTipCard(hasGallery: _pickedImage != null),
          ),

          //  Bottom controls 
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomControls(
              state: _state,
              progress: _progress,
              btnPulseAnim: _btnPulseAnim,
              onCapture: _captureAndScan,
              onReset: _reset,
              onPickGallery: _pickFromGallery,
            ),
          ),
        ],
      ),
    );
  }
}

//  Frame Vignette 

class _FrameVignette extends StatelessWidget {
  const _FrameVignette({
    required this.frameW,
    required this.frameH,
    required this.size,
  });
  final double frameW;
  final double frameH;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _VignettePainter(frameW: frameW, frameH: frameH),
    );
  }
}

class _VignettePainter extends CustomPainter {
  _VignettePainter({required this.frameW, required this.frameH});
  final double frameW;
  final double frameH;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: frameW,
      height: frameH,
    );

    final paint = Paint()..color = Colors.black.withOpacityCompat(0.72);

    // Top
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, rect.top), paint);
    // Bottom
    canvas.drawRect(
      Rect.fromLTRB(0, rect.bottom, size.width, size.height),
      paint,
    );
    // Left
    canvas.drawRect(Rect.fromLTRB(0, rect.top, rect.left, rect.bottom), paint);
    // Right
    canvas.drawRect(
      Rect.fromLTRB(rect.right, rect.top, size.width, rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VignettePainter old) =>
      old.frameW != frameW || old.frameH != frameH;
}

//  Scan Frame 

class _ScanFrame extends StatelessWidget {
  const _ScanFrame({
    required this.width,
    required this.height,
    required this.scanLineAnim,
    required this.isScanning,
    required this.progress,
  });
  final double width;
  final double height;
  final Animation<double> scanLineAnim;
  final bool isScanning;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Frame border glow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.scannerFrame, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.scannerGlow,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Corner brackets
          ..._buildBrackets(),

          // Animated scan line
          AnimatedBuilder(
            animation: scanLineAnim,
            builder: (_, _) {
              final topPos = 16 + (height - 32) * scanLineAnim.value;
              return Positioned(
                top: topPos,
                left: 12,
                right: 12,
                child: _ScanLine(opacity: isScanning ? 1.0 : 0.6),
              );
            },
          ),

          // Scanning highlight overlay
          if (isScanning)
            AnimatedBuilder(
              animation: scanLineAnim,
              builder: (_, _) {
                final splitY = 16 + (height - 32) * scanLineAnim.value;
                return Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  height: splitY - 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.scannerHighlight,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBrackets() {
    const len = 28.0;
    const thick = 3.0;
    const r = 8.0;
    const pad = 0.0;

    return [
      // Top-left
      Positioned(
        top: pad,
        left: pad,
        child: _Bracket(
          length: len,
          thickness: thick,
          radius: r,
          flipX: false,
          flipY: false,
        ),
      ),
      // Top-right
      Positioned(
        top: pad,
        right: pad,
        child: _Bracket(
          length: len,
          thickness: thick,
          radius: r,
          flipX: true,
          flipY: false,
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: pad,
        left: pad,
        child: _Bracket(
          length: len,
          thickness: thick,
          radius: r,
          flipX: false,
          flipY: true,
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: pad,
        right: pad,
        child: _Bracket(
          length: len,
          thickness: thick,
          radius: r,
          flipX: true,
          flipY: true,
        ),
      ),
    ];
  }
}

//  Bracket corner 

class _Bracket extends StatelessWidget {
  const _Bracket({
    required this.length,
    required this.thickness,
    required this.radius,
    required this.flipX,
    required this.flipY,
  });
  final double length;
  final double thickness;
  final double radius;
  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipX ? -1 : 1,
      scaleY: flipY ? -1 : 1,
      child: CustomPaint(
        size: Size(length, length),
        painter: _BracketPainter(
          color: AppColors.scannerFrame,
          strokeWidth: thickness,
          radius: radius,
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });
  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(radius, 0)
      ..arcToPoint(
        Offset(0, radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}

//  Scan Line 

class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main line
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.scannerLine,
                  AppColors.scannerLine,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.scannerLine.withOpacityCompat(0.9),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.scannerLine.withOpacityCompat(0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          // Soft glow below line
          Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.scannerLine.withOpacityCompat(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  Top Bar 

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacityCompat(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacityCompat(0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Text(
            'AI Scanner',
            style: AppTextStyles.headingLG.copyWith(color: Colors.white),
          ),

          const Spacer(),

          // History button
          _TopBarAction(icon: Icons.history_rounded, onTap: () {}),
          const SizedBox(width: 10),
          // Bookmark button
          _TopBarAction(icon: Icons.bookmark_outline_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _TopBarAction extends StatelessWidget {
  const _TopBarAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacityCompat(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacityCompat(0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

//  Title Prompt 

class _TitlePrompt extends StatelessWidget {
  const _TitlePrompt({required this.state, required this.progress});
  final _ScanState state;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (state) {
        _ScanState.idle => _titleRow(
          key: const ValueKey('idle'),
          white: 'Scan Your ',
          amber: 'Question',
        ),
        _ScanState.scanning => _titleRow(
          key: const ValueKey('scanning'),
          white: 'Analysing your ',
          amber: 'Notes',
        ),
        _ScanState.done => _titleRow(
          key: const ValueKey('done'),
          white: 'Scan ',
          amber: 'Complete ',
        ),
        _ScanState.error => _titleRow(
          key: const ValueKey('error'),
          white: 'Something went ',
          amber: 'wrong',
        ),
      },
    );
  }

  Widget _titleRow({
    required Key key,
    required String white,
    required String amber,
  }) {
    return Center(
      key: key,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: white, style: AppTextStyles.scannerTitle),
            TextSpan(text: amber, style: AppTextStyles.scannerAccent),
          ],
        ),
      ),
    );
  }
}

class _ScanTipCard extends StatelessWidget {
  const _ScanTipCard({required this.hasGallery});
  final bool hasGallery;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      opacity: 0.1,
      blur: 10,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasGallery
                  ? 'Gallery image loaded. Tap scan to extract text.'
                  : 'Keep the page inside the frame for best results.',
              style: AppTextStyles.bodySM.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  Bottom Controls 

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.state,
    required this.progress,
    required this.btnPulseAnim,
    required this.onCapture,
    required this.onReset,
    required this.onPickGallery,
  });
  final _ScanState state;
  final double progress;
  final Animation<double> btnPulseAnim;
  final VoidCallback onCapture;
  final VoidCallback onReset;
  final VoidCallback onPickGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacityCompat(0.92)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        32,
        24,
        32,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar (scanning state)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: state == _ScanState.scanning
                ? Padding(
                    key: const ValueKey('progress'),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _ProgressSection(progress: progress),
                  )
                : const SizedBox.shrink(key: ValueKey('no-progress')),
          ),

          // Main row: gallery | capture | mic
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gallery import
              _SecondaryBtn(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onPickGallery,
              ),

              // Capture button
              _CaptureButton(
                state: state,
                pulseAnim: btnPulseAnim,
                onTap: state == _ScanState.idle ? onCapture : onReset,
              ),

              // Voice note
              _SecondaryBtn(
                icon: Icons.mic_none_rounded,
                label: 'Voice',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//  Progress Section 

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Track
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacityCompat(0.12),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: AppColors.scannerGradient,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withOpacityCompat(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Percentage label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.headingMD.copyWith(color: AppColors.amber),
            ),
            const SizedBox(width: 8),
            Text(
              'Extracting text',
              style: AppTextStyles.bodyMD.copyWith(
                color: Colors.white.withOpacityCompat(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//  Capture Button 

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.state,
    required this.pulseAnim,
    required this.onTap,
  });
  final _ScanState state;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isScanning = state == _ScanState.scanning;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: isScanning ? 1.0 : pulseAnim.value,
          child: child,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring glow
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isScanning
                      ? Colors.white.withOpacityCompat(0.2)
                      : AppColors.amber.withOpacityCompat(0.35),
                  width: 2,
                ),
                boxShadow: isScanning
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.amber.withOpacityCompat(0.4),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
              ),
            ),

            // Inner button
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isScanning
                    ? const LinearGradient(
                        colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                      )
                    : AppColors.scannerGradient,
                boxShadow: isScanning ? [] : AppColors.amberShadow,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isScanning
                      ? const Icon(
                          Icons.close_rounded,
                          key: ValueKey('close'),
                          color: Colors.white,
                          size: 26,
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          key: ValueKey('camera'),
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Secondary Button 

class _SecondaryBtn extends StatelessWidget {
  const _SecondaryBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacityCompat(0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacityCompat(0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelMD.copyWith(
              color: Colors.white.withOpacityCompat(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

//  Save Bottom Sheet 

class _SaveSheet extends StatefulWidget {
  const _SaveSheet({
    required this.extractedText,
    required this.onSave,
    required this.onDiscard,
  });
  final String extractedText;
  final void Function(String, String) onSave;
  final VoidCallback onDiscard;

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.amberDim,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.amber,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan Complete', style: AppTextStyles.headingMD),
                  Text(
                    '${widget.extractedText.split(' ').length} words extracted',
                    style: AppTextStyles.bodySM,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Extracted preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.extractedText,
              style: AppTextStyles.bodyMD,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 20),

          // Title field
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.bodyMDMedium,
            decoration: const InputDecoration(
              hintText: 'Document title',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),

          const SizedBox(height: 12),

          // Subject field
          TextField(
            controller: _subjectCtrl,
            style: AppTextStyles.bodyMDMedium,
            decoration: const InputDecoration(
              hintText: 'Subject (e.g. Mathematics)',
              prefixIcon: Icon(Icons.school_rounded),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: PeckButton(
                  label: 'Discard',
                  onPressed: widget.onDiscard,
                  variant: PeckButtonVariant.secondary,
                  height: 50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PeckButton(
                  label: 'Save & Generate Cards',
                  onPressed: () => widget.onSave(
                    _titleCtrl.text.trim(),
                    _subjectCtrl.text.trim(),
                  ),
                  variant: PeckButtonVariant.primary,
                  height: 50,
                  icon: const Icon(Icons.auto_awesome_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


