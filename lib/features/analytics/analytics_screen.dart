// lib/features/analytics/analytics_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/glow_container.dart';
import '../../core/widgets/stat_tile.dart';
import '../../core/services/analytics_service.dart';

// ─── Screen ─────────────────────────────────────────────────────────────────────

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

  AnalyticsData? _data;
  late final StreamSubscription<AnalyticsData> _sub;

  Future<void> _loadData() async {
    final d = await AnalyticsService.instance.getData();
    if (!mounted) return;
    setState(() => _data = d);
    _chartCtrl.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _chartAnim = CurvedAnimation(parent: _chartCtrl, curve: Curves.easeOutCubic);
    _loadData();
    // Subscribe to real-time updates
    _sub = AnalyticsService.instance.stream.listen((d) {
      if (!mounted) return;
      setState(() => _data = d);
      _chartCtrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _chartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: _data == null
          ? _LoadingShimmer()
          : CustomScrollView(
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
              child: _data == null ? const SizedBox() : _TopStatsRow(data: _data!),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Activity chart ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _data == null
                  ? const SizedBox()
                  : _ActivityChartCard(anim: _chartAnim, data: _data!),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Streak + time row ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _data == null
                  ? const SizedBox()
                  : _StreakTimeRow(anim: _chartAnim, data: _data!),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Subject mastery ────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Subject Mastery',
              padding: EdgeInsets.symmetric(horizontal: 24),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          if (_data != null && _data!.subjects.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: _EmptySubjectsCard(),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                  child: _SubjectMasteryRow(
                    subject: _data!.subjects[i],
                    anim: _chartAnim,
                    rank: i,
                  ),
                ),
                childCount: _data?.subjects.length ?? 0,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Heatmap ────────────────────────────────────────────
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
              child: _data == null
                  ? const SizedBox()
                  : _HeatmapCard(data: _data!.heatmap),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Weak topics ───────────────────────────────────────
          if (_data != null && _data!.weakTopics.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Needs Review',
                action: 'Weak Topics',
                padding: EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _data!.weakTopics
                      .map((topic) => PeckBadge(
                            label: topic,
                            color: AppColors.error,
                            style: BadgeStyle.subtle,
                          ))
                      .toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],

          // ── World ranking card ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _data == null
                  ? const SizedBox()
                  : _WorldRankCard(anim: _chartAnim, data: _data!),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────────

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                child: Icon(
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
                  Icon(Icons.tune_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('This week', style: AppTextStyles.labelLG),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

// ─── Top Stats Row ───────────────────────────────────────────────────────────────

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow({required this.data});
  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: data.studyTimeMinutes == 0
                    ? '0m'
                    : '${data.studyTimeMinutes ~/ 60}h ${data.studyTimeMinutes % 60}m',
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
                value: '#${data.worldRank}',
                label: 'World rank',
                color: AppColors.violet,
                icon: const Icon(Icons.public_rounded),
                trend: '+12',
                trendUp: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: '${data.totalDocuments}',
                label: 'Documents',
                color: AppColors.success,
                icon: const Icon(Icons.description_outlined),
                trend: '',
                trendUp: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                value: data.totalQuizzesTaken == 0
                    ? '0%'
                    : '${(data.accuracy * 100).toInt()}%',
                label: 'Quiz accuracy',
                color: AppColors.error,
                icon: const Icon(Icons.quiz_outlined),
                trend: '${data.totalQuizzesTaken} taken',
                trendUp: data.accuracy >= 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Activity Chart Card ─────────────────────────────────────────────────────────

class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard({required this.anim, required this.data});
  final Animation<double> anim;
  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    return PeckCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity', style: AppTextStyles.headingMD),
                  const SizedBox(height: 2),
                  Text(
                    data.studyTimeMinutes == 0
                        ? 'No sessions yet'
                        : '${data.studyTimeMinutes ~/ 60}h ${data.studyTimeMinutes % 60}m this week',
                    style: AppTextStyles.bodyMD,
                  ),
                ],
              ),
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
            child: data.weekActivity.every((d) => d.minutes == 0)
                ? Center(
                    child: Text(
                      'No activity yet — start studying!',
                      style: AppTextStyles.bodyMD,
                    ),
                  )
                : AnimatedBuilder(
                    animation: anim,
                    builder: (_, _) => CustomPaint(
                      size: const Size(double.infinity, 140),
                      painter: _BarChartPainter(
                        data: data.weekActivity,
                        progress: anim.value,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.weekActivity
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
              BoxShadow(color: color.withOpacityCompat(0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.labelMD),
      ],
    );
  }
}

// ─── Bar Chart Painter ───────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data, required this.progress});
  final List<DayActivity> data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxMinutes = data.map((d) => d.minutes).reduce(math.max).toDouble();
    if (maxMinutes == 0) return;

    final barWidth = size.width / (data.length * 2 + 1);
    final spacing = barWidth;
    final maxHeight = size.height - 8;

    final guidePaint = Paint()
      ..color = AppColors.border.withOpacityCompat(0.4)
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

      final isAccent =
          data[i].minutes == maxMinutes || data[i].minutes > maxMinutes * 0.7;
      final barColor = isAccent ? AppColors.amber : AppColors.violet;

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [barColor, barColor.withOpacityCompat(0.4)],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barH));

      canvas.drawRRect(rect, barPaint);

      if (progress > 0.8 && isAccent) {
        final glowPaint = Paint()
          ..color = barColor.withOpacityCompat(0.35)
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

// ─── Streak + Time Row ───────────────────────────────────────────────────────────

class _StreakTimeRow extends StatelessWidget {
  const _StreakTimeRow({required this.anim, required this.data});
  final Animation<double> anim;
  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    // Calculate streak from heatmap (last N consecutive non-zero days from end)
    int streak = 0;
    for (int i = data.heatmap.length - 1; i >= 0; i--) {
      if (data.heatmap[i] > 0) {
        streak++;
      } else {
        break;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak card
        Expanded(
          child: PeckCard(
            padding: const EdgeInsets.all(18),
            borderColor: AppColors.amber.withOpacityCompat(0.25),
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
                  '$streak',
                  style: AppTextStyles.statLG.copyWith(color: AppColors.amber),
                ),
                Text('days in a row', style: AppTextStyles.bodyMD),
                const SizedBox(height: 14),

                // Mini week dots
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.start,
                  children: List.generate(7, (i) {
                    final idx = data.heatmap.length - 7 + i;
                    final hasActivity = idx >= 0 && idx < data.heatmap.length && data.heatmap[idx] > 0;
                    return AnimatedBuilder(
                      animation: anim,
                      builder: (_, _) => AnimatedContainer(
                        duration: Duration(milliseconds: 300 + i * 60),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasActivity
                              ? AppColors.amber.withOpacityCompat(
                                  anim.value.clamp(0.0, 1.0),
                                )
                              : AppColors.border,
                          boxShadow: hasActivity && anim.value > 0.8
                              ? [
                                  BoxShadow(
                                    color: AppColors.amber.withOpacityCompat(0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                            style: AppTextStyles.labelMD.copyWith(
                              color: hasActivity
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
            borderColor: AppColors.violet.withOpacityCompat(0.25),
            glowColor: AppColors.violet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time in app', style: AppTextStyles.headingSM),
                    Icon(
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
                          builder: (_, _) {
                            final goalMins = 7 * 60; // 7h weekly goal
                            final ratio = (data.studyTimeMinutes / goalMins)
                                .clamp(0.0, 1.0);
                            return CircularProgressIndicator(
                              value: ratio * anim.value,
                              strokeWidth: 7,
                              color: AppColors.violet,
                              backgroundColor: AppColors.border,
                              strokeCap: StrokeCap.round,
                            );
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${data.studyTimeMinutes ~/ 60}h',
                              style: AppTextStyles.statMD.copyWith(
                                color: AppColors.violet,
                              ),
                            ),
                            Text(
                              'this week',
                              style: AppTextStyles.labelMD.copyWith(fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: Text(
                    data.studyTimeMinutes == 0
                        ? 'No sessions yet'
                        : 'Avg ${data.studyTimeMinutes ~/ 7}m / day',
                    style: AppTextStyles.bodyMD,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Empty Subjects Card ─────────────────────────────────────────────────────────

class _EmptySubjectsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PeckCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.auto_stories_rounded,
              size: 36, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'No subjects yet',
            style: AppTextStyles.headingSM,
          ),
          const SizedBox(height: 4),
          Text(
            'Scan a note to generate flashcards and build subject mastery.',
            style: AppTextStyles.bodyMD,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Subject Mastery Row ─────────────────────────────────────────────────────────

class _SubjectMasteryRow extends StatelessWidget {
  const _SubjectMasteryRow({
    required this.subject,
    required this.anim,
    required this.rank,
  });
  final SubjectMastery subject;
  final Animation<double> anim;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.colorValue);
    return PeckCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacityCompat(0.18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacityCompat(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    subject.subject.isNotEmpty ? subject.subject[0] : '?',
                    style: AppTextStyles.headingMD.copyWith(color: color),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.subject, style: AppTextStyles.headingSM),
                    Text('${subject.cards} cards', style: AppTextStyles.bodyMD),
                  ],
                ),
              ),

              Text(
                '${(subject.mastery * 100).toInt()}%',
                style: AppTextStyles.headingMD.copyWith(color: color),
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
                        colors: [color, color.withOpacityCompat(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacityCompat(0.45),
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

// ─── Heatmap Card ────────────────────────────────────────────────────────────────

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.data});
  final List<int> data; // values 0–4

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Color _cellColor(int value) {
    return switch (value) {
      0 => AppColors.border,
      1 => AppColors.amber.withOpacityCompat(0.20),
      2 => AppColors.amber.withOpacityCompat(0.45),
      3 => AppColors.amber.withOpacityCompat(0.70),
      _ => AppColors.amber,
    };
  }

  @override
  Widget build(BuildContext context) {
    const weeks = 5;

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
                                    color: AppColors.amber.withOpacityCompat(0.3),
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

// ─── World Rank Card ─────────────────────────────────────────────────────────────

class _WorldRankCard extends StatelessWidget {
  const _WorldRankCard({required this.anim, required this.data});
  final Animation<double> anim;
  final AnalyticsData data;

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
            color: AppColors.violet.withOpacityCompat(0.25),
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
                  '#${data.worldRank}',
                  style: AppTextStyles.statLG.copyWith(color: AppColors.violet),
                ),
                const SizedBox(height: 4),
                Text('Keep studying to rank up 🌍', style: AppTextStyles.bodyMD),
                const SizedBox(height: 2),
                Text(
                  data.studyTimeMinutes > 0
                      ? 'Active learner 📈'
                      : 'Start scanning notes!',
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

// ─── Sparkline Painter ───────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.progress});
  final double progress;

  static const _points = [0.8, 0.6, 0.75, 0.5, 0.65, 0.4, 0.3];

  @override
  void paint(Canvas canvas, Size size) {
    if (_points.isEmpty) return;

    final stepX = size.width / (_points.length - 1);

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

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.violet.withOpacityCompat(0.25), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.violet
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    if (progress > 0.9) {
      final lastX = (_points.length - 1) * stepX;
      final lastY = size.height * (1 - _points.last);
      canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = AppColors.violet);
      canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = Colors.white);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.progress != progress;
}

// ─── Loading Shimmer ─────────────────────────────────────────────────────────

class _LoadingShimmer extends StatefulWidget {
  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmerColor = Color.lerp(AppColors.bgCard, AppColors.bgSurface, _anim.value)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _ShimmerBox(w: 40, h: 40, color: shimmerColor, radius: 12),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _ShimmerBox(w: 100, h: 12, color: shimmerColor, radius: 6),
                    const SizedBox(height: 6),
                    _ShimmerBox(w: 160, h: 20, color: shimmerColor, radius: 6),
                  ]),
                ]),
                const SizedBox(height: 28),
                Row(children: [
                  Expanded(child: _ShimmerBox(w: double.infinity, h: 80, color: shimmerColor, radius: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: _ShimmerBox(w: double.infinity, h: 80, color: shimmerColor, radius: 16)),
                ]),
                const SizedBox(height: 20),
                _ShimmerBox(w: double.infinity, h: 200, color: shimmerColor, radius: 18),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _ShimmerBox(w: double.infinity, h: 160, color: shimmerColor, radius: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: _ShimmerBox(w: double.infinity, h: 160, color: shimmerColor, radius: 16)),
                ]),
                const SizedBox(height: 20),
                _ShimmerBox(w: 140, h: 18, color: shimmerColor, radius: 6),
                const SizedBox(height: 12),
                _ShimmerBox(w: double.infinity, h: 70, color: shimmerColor, radius: 16),
                const SizedBox(height: 10),
                _ShimmerBox(w: double.infinity, h: 70, color: shimmerColor, radius: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.w, required this.h, required this.color, required this.radius});
  final double w;
  final double h;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: w == double.infinity ? null : w,
        height: h,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      );
}

