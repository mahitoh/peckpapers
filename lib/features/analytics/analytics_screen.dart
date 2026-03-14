// lib/features/analytics/analytics_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/glow_container.dart';
import '../../core/widgets/stat_tile.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

class _DayActivity {
  const _DayActivity({required this.day, required this.minutes});
  final String day;
  final int minutes;
}

class _SubjectMastery {
  const _SubjectMastery({
    required this.subject,
    required this.mastery,
    required this.cards,
    required this.color,
  });
  final String subject;
  final double mastery; // 0.0 – 1.0
  final int cards;
  final Color color;
}

const _weekActivity = [
  _DayActivity(day: 'Mon', minutes: 24),
  _DayActivity(day: 'Tue', minutes: 45),
  _DayActivity(day: 'Wed', minutes: 18),
  _DayActivity(day: 'Thu', minutes: 62),
  _DayActivity(day: 'Fri', minutes: 38),
  _DayActivity(day: 'Sat', minutes: 80),
  _DayActivity(day: 'Sun', minutes: 30),
];

const _subjects = [
  _SubjectMastery(
    subject: 'Mathematics',
    mastery: 0.78,
    cards: 124,
    color: AppColors.amber,
  ),
  _SubjectMastery(
    subject: 'Physics',
    mastery: 0.54,
    cards: 86,
    color: AppColors.violet,
  ),
  _SubjectMastery(
    subject: 'Chemistry',
    mastery: 0.42,
    cards: 98,
    color: AppColors.error,
  ),
  _SubjectMastery(
    subject: 'Economics',
    mastery: 0.91,
    cards: 62,
    color: AppColors.success,
  ),
  _SubjectMastery(
    subject: 'History',
    mastery: 0.65,
    cards: 44,
    color: AppColors.warning,
  ),
];

// Heatmap — 35 days, value 0-4
final _heatmap = List.generate(35, (i) => math.Random(i * 7).nextInt(5));

// ─── Screen ───────────────────────────────────────────────────────────────────

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartCtrl;
  late Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _chartAnim = CurvedAnimation(
      parent: _chartCtrl,
      curve: Curves.easeOutCubic,
    );
    // Slight delay so screen entrance feels clean
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _chartCtrl.forward();
    });
  }

  @override
  void dispose() {
    _chartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _AnalyticsHeader(
              onBack: widget.onBack ?? () => Navigator.pop(context),
            ),
          ),

          // ── Top stats row ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: _TopStatsRow(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Activity chart ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ActivityChartCard(anim: _chartAnim),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Streak + time row ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StreakTimeRow(anim: _chartAnim),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Subject mastery ──────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Subject Mastery',
              padding: EdgeInsets.symmetric(horizontal: 24),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: _SubjectMasteryRow(
                  subject: _subjects[i],
                  anim: _chartAnim,
                  rank: i,
                ),
              ),
              childCount: _subjects.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Heatmap ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Study Heatmap',
              action: 'Last 35 days',
              padding: EdgeInsets.symmetric(horizontal: 24),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _HeatmapCard(data: _heatmap),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── World ranking card ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _WorldRankCard(anim: _chartAnim),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 24, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Progress', style: AppTextStyles.bodyMD),
                  Text('Statistics', style: AppTextStyles.headingXL),
                ],
              ),
            ),
            // Filter chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text('This week', style: AppTextStyles.labelLG),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Stats Row ────────────────────────────────────────────────────────────

class _TopStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatTile(
            value: '4h 20m',
            label: 'Study time',
            color: AppColors.amber,
            icon: const Icon(Icons.timer_outlined),
            trend: '+18%',
            trendUp: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatTile(
            value: '186',
            label: 'World rank',
            color: AppColors.violet,
            icon: const Icon(Icons.public_rounded),
            trend: '+12',
            trendUp: true,
          ),
        ),
      ],
    );
  }
}

// ─── Activity Chart Card ──────────────────────────────────────────────────────

class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard({required this.anim});
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return PeckCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity', style: AppTextStyles.headingMD),
                  const SizedBox(height: 2),
                  Text('30h 50m this week', style: AppTextStyles.bodyMD),
                ],
              ),
              // Legend
              Row(
                children: [
                  _LegendDot(color: AppColors.amber, label: 'Study'),
                  const SizedBox(width: 12),
                  _LegendDot(color: AppColors.violet, label: 'Review'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 140,
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, _) => CustomPaint(
                size: const Size(double.infinity, 140),
                painter: _BarChartPainter(
                  data: _weekActivity,
                  progress: anim.value,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekActivity
                .map(
                  (d) => Text(
                    d.day,
                    style: AppTextStyles.labelMD.copyWith(fontSize: 10),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.labelMD),
      ],
    );
  }
}

// ─── Bar Chart Painter ────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data, required this.progress});
  final List<_DayActivity> data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxMinutes = data.map((d) => d.minutes).reduce(math.max).toDouble();
    final barWidth = size.width / (data.length * 2 + 1);
    final spacing = barWidth;
    final maxHeight = size.height - 8;

    // Horizontal guide lines
    final guidePaint = Paint()
      ..color = AppColors.border.withOpacity(0.4)
      ..strokeWidth = 1;

    for (var i = 1; i <= 4; i++) {
      final y = size.height - (maxHeight * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guidePaint);
    }

    for (var i = 0; i < data.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final normalised = data[i].minutes / maxMinutes;
      final barH = maxHeight * normalised * progress;
      final y = size.height - barH;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barH),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      // Determine bar colour — alternate amber/violet for variety
      final isAccent =
          data[i].minutes == maxMinutes || data[i].minutes > maxMinutes * 0.7;
      final barColor = isAccent ? AppColors.amber : AppColors.violet;

      // Bar fill
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [barColor, barColor.withOpacity(0.4)],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barH));

      canvas.drawRRect(rect, barPaint);

      // Glow at top of bar
      if (progress > 0.8 && isAccent) {
        final glowPaint = Paint()
          ..color = barColor.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(
          Offset(x + barWidth / 2, y + 3),
          barWidth * 0.8,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}

// ─── Streak + Time Row ────────────────────────────────────────────────────────

class _StreakTimeRow extends StatelessWidget {
  const _StreakTimeRow({required this.anim});
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Streak card
        Expanded(
          child: PeckCard(
            padding: const EdgeInsets.all(18),
            borderColor: AppColors.amber.withOpacity(0.25),
            glowColor: AppColors.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Streak', style: AppTextStyles.headingSM),
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '8',
                  style: AppTextStyles.statLG.copyWith(color: AppColors.amber),
                ),
                Text('days in a row', style: AppTextStyles.bodyMD),
                const SizedBox(height: 14),

                // Mini week dots - wrapped to prevent overflow
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.start,
                  children: List.generate(7, (i) {
                    final done = i < 6;
                    return AnimatedBuilder(
                      animation: anim,
                      builder: (_, _) => AnimatedContainer(
                        duration: Duration(milliseconds: 300 + i * 60),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? AppColors.amber.withOpacity(
                                  anim.value.clamp(0.0, 1.0),
                                )
                              : AppColors.border,
                          boxShadow: done && anim.value > 0.8
                              ? [
                                  BoxShadow(
                                    color: AppColors.amber.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                            style: AppTextStyles.labelMD.copyWith(
                              color: done
                                  ? AppColors.textInverse
                                  : AppColors.textTertiary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Time in app card
        Expanded(
          child: PeckCard(
            padding: const EdgeInsets.all(18),
            borderColor: AppColors.violet.withOpacity(0.25),
            glowColor: AppColors.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time in app', style: AppTextStyles.headingSM),
                    const Icon(
                      Icons.access_time_rounded,
                      color: AppColors.violet,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Circular time ring
                Center(
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: anim,
                          builder: (_, _) => CircularProgressIndicator(
                            value: 0.67 * anim.value,
                            strokeWidth: 7,
                            color: AppColors.violet,
                            backgroundColor: AppColors.border,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '16h',
                              style: AppTextStyles.statMD.copyWith(
                                color: AppColors.violet,
                              ),
                            ),
                            Text(
                              'this week',
                              style: AppTextStyles.labelMD.copyWith(
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Daily average
                Center(
                  child: Text('Avg 2h 17m / day', style: AppTextStyles.bodyMD),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Subject Mastery Row ──────────────────────────────────────────────────────

class _SubjectMasteryRow extends StatelessWidget {
  const _SubjectMasteryRow({
    required this.subject,
    required this.anim,
    required this.rank,
  });
  final _SubjectMastery subject;
  final Animation<double> anim;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return PeckCard(
      padding: const EdgeInsets.all(16),
      borderColor: subject.color.withOpacity(0.18),
      child: Column(
        children: [
          Row(
            children: [
              // Subject icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    subject.subject[0],
                    style: AppTextStyles.headingMD.copyWith(
                      color: subject.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + cards
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.subject, style: AppTextStyles.headingSM),
                    Text('${subject.cards} cards', style: AppTextStyles.bodyMD),
                  ],
                ),
              ),

              // Percentage
              Text(
                '${(subject.mastery * 100).toInt()}%',
                style: AppTextStyles.headingMD.copyWith(color: subject.color),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Animated mastery bar
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedBuilder(
                animation: anim,
                builder: (_, _) => FractionallySizedBox(
                  widthFactor: subject.mastery * anim.value,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [subject.color, subject.color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: subject.color.withOpacity(0.45),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Heatmap Card ─────────────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.data});
  final List<int> data; // values 0–4

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Color _cellColor(int value) {
    return switch (value) {
      0 => AppColors.border,
      1 => AppColors.amber.withOpacity(0.20),
      2 => AppColors.amber.withOpacity(0.45),
      3 => AppColors.amber.withOpacity(0.70),
      _ => AppColors.amber,
    };
  }

  @override
  Widget build(BuildContext context) {
    // 5 weeks × 7 days = 35 cells
    final weeks = 5;

    return PeckCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          Row(
            children: [
              const SizedBox(width: 2),
              ...List.generate(
                7,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      _days[i],
                      style: AppTextStyles.labelMD.copyWith(fontSize: 9),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Grid
          ...List.generate(weeks, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: List.generate(7, (day) {
                  final idx = week * 7 + day;
                  final value = idx < data.length ? data[idx] : 0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: _cellColor(value),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: value >= 3
                              ? [
                                  BoxShadow(
                                    color: AppColors.amber.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: AppTextStyles.labelMD.copyWith(fontSize: 9)),
              const SizedBox(width: 6),
              ...List.generate(
                5,
                (i) => Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _cellColor(i),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('More', style: AppTextStyles.labelMD.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── World Rank Card ──────────────────────────────────────────────────────────

class _WorldRankCard extends StatelessWidget {
  const _WorldRankCard({required this.anim});
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      glowColor: AppColors.violet,
      glowRadius: 40,
      glowOpacity: 0.18,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1A2E), Color(0xFF14121F)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.violet.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Rank column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PeckBadge(
                  label: 'Global Ranking',
                  color: AppColors.violet,
                  style: BadgeStyle.subtle,
                ),
                const SizedBox(height: 12),
                Text(
                  '#186',
                  style: AppTextStyles.statLG.copyWith(color: AppColors.violet),
                ),
                const SizedBox(height: 4),
                Text('You are the 186th', style: AppTextStyles.bodyMD),
                const SizedBox(height: 2),
                Text(
                  'Top 2% worldwide 🌍',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Mini sparkline
            SizedBox(
              width: 100,
              height: 60,
              child: AnimatedBuilder(
                animation: anim,
                builder: (_, _) => CustomPaint(
                  painter: _SparklinePainter(progress: anim.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sparkline Painter ────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.progress});
  final double progress;

  static const _points = [0.8, 0.6, 0.75, 0.5, 0.65, 0.4, 0.3];

  @override
  void paint(Canvas canvas, Size size) {
    if (_points.isEmpty) return;

    final stepX = size.width / (_points.length - 1);

    // Build path
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - _points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final px = (i - 1) * stepX;
        final py = size.height * (1 - _points[i - 1]);
        final cx1 = px + stepX * 0.5;
        final cx2 = x - stepX * 0.5;
        path.cubicTo(cx1, py, cx2, y, x, y);
      }
    }

    // Clip to progress
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    // Fill under line
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.violet.withOpacity(0.25), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Dot at latest point
    if (progress > 0.9) {
      final lastX = (_points.length - 1) * stepX;
      final lastY = size.height * (1 - _points.last);
      canvas.drawCircle(
        Offset(lastX, lastY),
        5,
        Paint()..color = AppColors.violet,
      );
      canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = Colors.white);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.progress != progress;
}
