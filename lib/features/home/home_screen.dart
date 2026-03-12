// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';
import '../../core/widgets/peck_button.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/stat_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/glow_container.dart';

// ─── Fake data models (replace with your state management) ───────────────────

class _RecentDoc {
  const _RecentDoc({
    required this.title,
    required this.subject,
    required this.progress,
    required this.cardCount,
    required this.color,
    required this.icon,
  });
  final String title;
  final String subject;
  final double progress;
  final int cardCount;
  final Color color;
  final IconData icon;
}

const _mockDocs = [
  _RecentDoc(
    title: 'Calculus — Integration',
    subject: 'Mathematics',
    progress: 0.72,
    cardCount: 24,
    color: AppColors.amber,
    icon: Icons.functions_rounded,
  ),
  _RecentDoc(
    title: 'Organic Chemistry Pt.2',
    subject: 'Chemistry',
    progress: 0.45,
    cardCount: 38,
    color: AppColors.violet,
    icon: Icons.science_rounded,
  ),
  _RecentDoc(
    title: 'World War II — Causes',
    subject: 'History',
    progress: 0.91,
    cardCount: 16,
    color: AppColors.success,
    icon: Icons.history_edu_rounded,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onScanTap,
    this.onDocTap,
    this.onSeeAllTap,
    this.onStatTap,
  });

  final VoidCallback? onScanTap;
  final ValueChanged<int>? onDocTap;
  final VoidCallback? onSeeAllTap;
  final VoidCallback? onStatTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listCtrl;
  final List<Animation<double>> _itemFades = [];
  final List<Animation<Offset>> _itemSlides = [];

  // Total animatable rows: 1 scan CTA + 1 stats row + 3 docs = 5
  static const _itemCount = 5;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    for (var i = 0; i < _itemCount; i++) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);

      _itemFades.add(
        CurvedAnimation(
          parent: _listCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
      _itemSlides.add(
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _listCtrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    _listCtrl.forward();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _animated(int index, Widget child) => FadeTransition(
    opacity: _itemFades[index],
    child: SlideTransition(position: _itemSlides[index], child: child),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(child: _Header(greeting: _greeting)),

          // ── Search bar ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _SearchBar(),
            ),
          ),

          // ── Scan CTA card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _animated(0, _ScanCtaCard(onTap: widget.onScanTap)),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Stats row ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _animated(
              1,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _StatsRow(onTap: widget.onStatTap),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── Section header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recent Notes',
              action: 'See all',
              onAction: widget.onSeeAllTap,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Document cards ────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _animated(
                  2 + i,
                  _DocCard(
                    doc: _mockDocs[i],
                    onTap: () => widget.onDocTap?.call(i),
                  ),
                ),
              ),
              childCount: _mockDocs.length,
            ),
          ),

          // ── Due cards nudge ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: _DueCardsNudge(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTextStyles.bodyMDMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.headingXL,
                      children: const [
                        TextSpan(text: 'PECK'),
                        TextSpan(
                          text: 'PAPERS',
                          style: TextStyle(color: AppColors.amber),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Avatar / profile chip
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.scannerGradient,
                  boxShadow: AppColors.amberShadow,
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textInverse,
                    ),
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

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Search notes, flashcards…',
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '⌘ K',
                style: AppTextStyles.labelMD.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scan CTA Card ────────────────────────────────────────────────────────────

class _ScanCtaCard extends StatefulWidget {
  const _ScanCtaCard({this.onTap});
  final VoidCallback? onTap;

  @override
  State<_ScanCtaCard> createState() => _ScanCtaCardState();
}

class _ScanCtaCardState extends State<_ScanCtaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: AppColors.scannerGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withOpacity(0.35 * _pulseAnim.value),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
        child: Stack(
          children: [
            // Background grid pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PeckBadge(
                          label: 'AI SCANNER',
                          color: AppColors.textInverse,
                          style: BadgeStyle.subtle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Scan New Notes',
                          style: AppTextStyles.headingXL.copyWith(
                            color: AppColors.textInverse,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Point. Shoot. Learn instantly.',
                          style: AppTextStyles.bodySM.copyWith(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Camera icon circle
                  GlowContainer(
                    glowColor: Colors.white,
                    glowRadius: 30,
                    glowOpacity: 0.25,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid painter for CTA card texture
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: '12',
            label: 'Due cards',
            color: AppColors.amber,
            icon: const Icon(Icons.style_rounded),
            trend: '+3',
            trendUp: true,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            value: '4h 20m',
            label: 'This week',
            color: AppColors.violet,
            icon: const Icon(Icons.timer_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            value: '7🔥',
            label: 'Day streak',
            color: AppColors.success,
            icon: const Icon(Icons.local_fire_department_rounded),
          ),
        ),
      ],
    );
  }
}

// ─── Document Card ────────────────────────────────────────────────────────────

class _DocCard extends StatelessWidget {
  const _DocCard({required this.doc, required this.onTap});
  final _RecentDoc doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PeckCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderColor: doc.color.withOpacity(0.18),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: doc.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: doc.color.withOpacity(0.2), width: 1),
            ),
            child: Icon(doc.icon, color: doc.color, size: 22),
          ),

          const SizedBox(width: 14),

          // Text + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: AppTextStyles.headingSM,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(doc.subject, style: AppTextStyles.labelLG),
                const SizedBox(height: 10),

                // Progress bar
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: doc.progress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: doc.color,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: doc.color.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right side: percentage + card count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(doc.progress * 100).toInt()}%',
                style: AppTextStyles.headingSM.copyWith(color: doc.color),
              ),
              const SizedBox(height: 4),
              Text('${doc.cardCount} cards', style: AppTextStyles.labelMD),
              const SizedBox(height: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Due Cards Nudge ──────────────────────────────────────────────────────────

class _DueCardsNudge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PeckCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.violet.withOpacity(0.3),
      glowColor: AppColors.violet,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.violetDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.violet,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('12 cards due for review', style: AppTextStyles.headingSM),
                const SizedBox(height: 2),
                Text(
                  'Best time to review is now.',
                  style: AppTextStyles.bodySM,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.violetGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppColors.violetShadow,
            ),
            child: Text(
              'Review',
              style: AppTextStyles.buttonSM.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
