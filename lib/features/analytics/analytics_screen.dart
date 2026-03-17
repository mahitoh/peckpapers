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
  final double mastery; // 0.0  1.0
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

final _subjects = [
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

final _heatmap = List.generate(35, (i) => math.Random(i * 7).nextInt(5));

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
          // --- Twitter-Style Top Bar ---
          SliverAppBar(
            floating: true,
            elevation: 0,
            backgroundColor: AppColors.bgBase.withOpacity(0.9),
            centerTitle: true,
            leadingWidth: 70,
            leading: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              'Statistics',
              style: AppTextStyles.headingMD.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share_outlined, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'This Week\'s Overview',
                      style: AppTextStyles.labelLG.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text('Last 7 Days', style: AppTextStyles.labelSM),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Top Stats ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      '82%',
                      'Avg. Score',
                      Icons.insights_rounded,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernStatCard(
                      '12h',
                      'Total Time',
                      Icons.timer_outlined,
                      AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- Mastery Feed Section ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SectionHeader(title: 'Subject Mastery'),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildMasteryFeedItem(_subjects[i]),
              childCount: _subjects.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- Activity Chart ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ActivityChartCard(anim: _chartAnim),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- Heatmap (GitHub like) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HeatmapCard(data: _heatmap),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          
          // --- Streak & Time ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StreakTimeRow(anim: _chartAnim),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headingLG.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelMD.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryFeedItem(_SubjectMastery subject) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: subject.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                subject.subject[0],
                style: AppTextStyles.headingMD.copyWith(color: subject.color),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject.subject,
                      style: AppTextStyles.bodyMDMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${(subject.mastery * 100).toInt()}%',
                      style: AppTextStyles.labelLG.copyWith(
                        color: subject.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: subject.mastery,
                    backgroundColor: AppColors.border,
                    color: subject.color,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${subject.cards} cards mastered  Keep it up!',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Activity Chart Card 

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

//  Bar Chart Painter 

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

      // Determine bar colour  alternate amber/violet for variety
      final isAccent =
          data[i].minutes == maxMinutes || data[i].minutes > maxMinutes * 0.7;
      final barColor = isAccent ? AppColors.amber : AppColors.violet;

      // Bar fill
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [barColor, barColor.withOpacityCompat(0.4)],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barH));

      canvas.drawRRect(rect, barPaint);

      // Glow at top of bar
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

//  Streak + Time Row 

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
            borderColor: AppColors.amber.withOpacityCompat(0.25),
            glowColor: AppColors.amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Streak', style: AppTextStyles.headingSM),
                    const Text('', style: TextStyle(fontSize: 20)),
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
                              ? AppColors.amber.withOpacityCompat(
                                  anim.value.clamp(0.0, 1.0),
                                )
                              : AppColors.border,
                          boxShadow: done && anim.value > 0.8
                              ? [
                                  BoxShadow(
                                    color: AppColors.amber.withOpacityCompat(
                                      0.4,
                                    ),
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

//  Subject Mastery Row 

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
      borderColor: subject.color.withOpacityCompat(0.18),
      child: Column(
        children: [
          Row(
            children: [
              // Subject icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: subject.color.withOpacityCompat(0.12),
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
                        colors: [
                          subject.color,
                          subject.color.withOpacityCompat(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: subject.color.withOpacityCompat(0.45),
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

//  Heatmap Card 

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.data});
  final List<int> data; // values 04

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
    // 5 weeks  7 days = 35 cells
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
                                    color: AppColors.amber.withOpacityCompat(
                                      0.3,
                                    ),
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

//  World Rank Card 

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
                  '#186',
                  style: AppTextStyles.statLG.copyWith(color: AppColors.violet),
                ),
                const SizedBox(height: 4),
                Text('You are the 186th', style: AppTextStyles.bodyMD),
                const SizedBox(height: 2),
                Text(
                  'Top 2% worldwide ',
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

//  Sparkline Painter 

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
        colors: [AppColors.violet.withOpacityCompat(0.25), Colors.transparent],
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


