// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_button.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.tag,
    required this.title,
    required this.titleAccent,
    required this.subtitle,
    required this.accentColor,
    required this.illustration,
  });

  final IconData icon;
  final String tag;
  final String title;
  final String titleAccent; // colored word inside the title
  final String subtitle;
  final Color accentColor;
  final _IllustrationStyle illustration;
}

enum _IllustrationStyle { scanner, flashcard, analytics }

const _pages = [
  _OnboardingPage(
    icon: Icons.document_scanner_rounded,
    tag: 'SMART OCR',
    title: 'Scan. Digitize.',
    titleAccent: 'Learn.',
    subtitle:
        'Point your camera at any handwritten or printed notes. PeckPapers reads them instantly — perfect lighting not required.',
    accentColor: AppColors.amber,
    illustration: _IllustrationStyle.scanner,
  ),
  _OnboardingPage(
    icon: Icons.style_rounded,
    tag: 'AI FLASHCARDS',
    title: 'Cards that',
    titleAccent: 'teach back.',
    subtitle:
        'AI reads your notes and builds spaced-repetition flashcards automatically. The right card at the right moment, every time.',
    accentColor: AppColors.violet,
    illustration: _IllustrationStyle.flashcard,
  ),
  _OnboardingPage(
    icon: Icons.analytics_rounded,
    tag: 'PERFORMANCE',
    title: 'Know what to',
    titleAccent: 'study next.',
    subtitle:
        'Visual dashboards surface exactly where you\'re struggling. No more guessing. No more wasted review sessions.',
    accentColor: AppColors.success,
    illustration: _IllustrationStyle.analytics,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  // Per-page entrance animations
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Glow pulse on illustration
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
        );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Kick off first entrance
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index >= _pages.length) {
      widget.onFinish();
      return;
    }
    _entranceCtrl.reset();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentPage = index);
    _entranceCtrl.forward();
  }

  void _next() => _goToPage(_currentPage + 1);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // ── Background radial glow ──────────────────────────────
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.25,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, _) => Opacity(
                opacity: _pulseAnim.value * 0.5,
                child: Container(
                  width: size.width * 1.5,
                  height: size.height * 0.65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        page.accentColor.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Skip button ────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 20),
                child: AnimatedOpacity(
                  opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: widget.onFinish,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMDMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Page content ───────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pages.length,
            itemBuilder: (_, i) => const SizedBox.shrink(),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.10),

                      // ── Illustration area ──────────────────────
                      Center(
                        child: _IllustrationWidget(
                          style: page.illustration,
                          accentColor: page.accentColor,
                          pulseAnim: _pulseAnim,
                          size: size.width * 0.62,
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      // ── Tag pill ───────────────────────────────
                      _TagPill(label: page.tag, color: page.accentColor),

                      const SizedBox(height: 16),

                      // ── Title ──────────────────────────────────
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.displayLG,
                          children: [
                            TextSpan(text: '${page.title}\n'),
                            TextSpan(
                              text: page.titleAccent,
                              style: AppTextStyles.displayLG.copyWith(
                                color: page.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Subtitle ───────────────────────────────
                      Text(
                        page.subtitle,
                        style: AppTextStyles.bodyLG.copyWith(height: 1.65),
                      ),

                      const Spacer(),

                      // ── Dots ───────────────────────────────────
                      Center(
                        child: _DotRow(
                          count: _pages.length,
                          current: _currentPage,
                          color: page.accentColor,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── CTA button ────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: PeckButton(
                          key: ValueKey(isLast),
                          label: isLast ? 'Get Started' : 'Continue',
                          onPressed: _next,
                          variant: PeckButtonVariant.primary,
                          trailingIcon: Icon(
                            isLast
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Secondary ghost action ─────────────────
                      if (!isLast)
                        Center(
                          child: TextButton(
                            onPressed: _next,
                            child: Text(
                              'I already know this',
                              style: AppTextStyles.bodyMD.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dot Row ──────────────────────────────────────────────────────────────────

class _DotRow extends StatelessWidget {
  const _DotRow({
    required this.count,
    required this.current,
    required this.color,
  });

  final int count;
  final int current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? color : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Tag Pill ─────────────────────────────────────────────────────────────────

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelCaps.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

// ─── Illustration Widget ──────────────────────────────────────────────────────

class _IllustrationWidget extends StatelessWidget {
  const _IllustrationWidget({
    required this.style,
    required this.accentColor,
    required this.pulseAnim,
    required this.size,
  });

  final _IllustrationStyle style;
  final Color accentColor;
  final Animation<double> pulseAnim;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, child) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12 * pulseAnim.value),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: child,
      ),
      child: Center(
        child: switch (style) {
          _IllustrationStyle.scanner => _ScannerIllustration(
            color: accentColor,
            size: size,
          ),
          _IllustrationStyle.flashcard => _FlashcardIllustration(
            color: accentColor,
            size: size,
          ),
          _IllustrationStyle.analytics => _AnalyticsIllustration(
            color: accentColor,
            size: size,
          ),
        },
      ),
    );
  }
}

// ── Scanner illustration ──────────────────────────────────────────────────────

class _ScannerIllustration extends StatelessWidget {
  const _ScannerIllustration({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * 0.55;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document outline
          Container(
            width: s * 0.72,
            height: s * 0.88,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == 0 ? color.withOpacity(0.6) : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Orange scan line
          Positioned(
            top: s * 0.38,
            child: Container(
              width: s * 0.72,
              height: 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    color,
                    color,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.8), blurRadius: 8),
                ],
              ),
            ),
          ),
          // Corner brackets
          ..._cornerBrackets(s * 0.72, s * 0.88, color),
        ],
      ),
    );
  }

  List<Widget> _cornerBrackets(double w, double h, Color c) {
    const br = 5.0;
    const len = 16.0;
    const thick = 2.5;
    Widget bracket(AlignmentGeometry align, bool flipX, bool flipY) {
      return Align(
        alignment: align,
        child: Transform.scale(
          scaleX: flipX ? -1 : 1,
          scaleY: flipY ? -1 : 1,
          child: SizedBox(
            width: len,
            height: len,
            child: CustomPaint(painter: _BracketPainter(c, br, thick)),
          ),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft, false, false),
      bracket(Alignment.topRight, true, false),
      bracket(Alignment.bottomLeft, false, true),
      bracket(Alignment.bottomRight, true, true),
    ];
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter(this.color, this.radius, this.strokeWidth);
  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(radius, 0)
      ..arcToPoint(Offset(0, radius), radius: Radius.circular(radius))
      ..lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}

// ── Flashcard illustration ────────────────────────────────────────────────────

class _FlashcardIllustration extends StatelessWidget {
  const _FlashcardIllustration({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * 0.55;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card
          Positioned(
            top: s * 0.06,
            left: s * 0.10,
            child: Transform.rotate(
              angle: -0.08,
              child: _MiniCard(
                width: s * 0.78,
                height: s * 0.54,
                color: color.withOpacity(0.10),
                border: color.withOpacity(0.2),
              ),
            ),
          ),
          // Front card
          Transform.rotate(
            angle: 0.04,
            child: _MiniCard(
              width: s * 0.78,
              height: s * 0.54,
              color: AppColors.bgCardHover,
              border: color.withOpacity(0.35),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q',
                      style: AppTextStyles.labelCaps.copyWith(color: color),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 5,
                      width: s * 0.4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Star badge
          Positioned(
            top: 0,
            right: s * 0.04,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 12),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.width,
    required this.height,
    required this.color,
    required this.border,
    this.child,
  });
  final double width;
  final double height;
  final Color color;
  final Color border;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border, width: 1.5),
    ),
    child: child,
  );
}

// ── Analytics illustration ────────────────────────────────────────────────────

class _AnalyticsIllustration extends StatelessWidget {
  const _AnalyticsIllustration({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size * 0.55;
    final bars = [0.40, 0.65, 0.50, 0.85, 0.60, 0.75, 0.55];
    final accents = [false, false, true, false, true, false, false];

    return SizedBox(
      width: s,
      height: s,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Mini label row
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'THIS WEEK',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: color,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bar chart
          SizedBox(
            height: s * 0.68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (i) {
                final isAccent = accents[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: s * 0.085,
                    height: s * 0.68 * bars[i],
                    decoration: BoxDecoration(
                      color: isAccent ? color : color.withOpacity(0.22),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                      boxShadow: isAccent
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          // Baseline
          Container(height: 1.5, width: s * 0.85, color: AppColors.border),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
