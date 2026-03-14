// lib/features/home/home_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/settings/app_settings_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../settings/settings_screen.dart';

// â”€â”€â”€ Models â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Task {
  const _Task({
    required this.title,
    required this.subject,
    required this.time,
    required this.priority,
    required this.color,
    required this.completed,
  });
  final String title;
  final String subject;
  final String time;
  final int priority;
  final Color color;
  final bool completed;
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

final _mockTasks = [
  _Task(
    title: 'Calculus â€” Integration',
    subject: 'Mathematics',
    time: '8:30 AM',
    priority: 3,
    color: AppColors.primary,
    completed: false,
  ),
  _Task(
    title: 'Organic Chemistry',
    subject: 'Chemistry',
    time: '9:45 AM',
    priority: 4,
    color: AppColors.accentOrange,
    completed: false,
  ),
  _Task(
    title: 'World War II',
    subject: 'History',
    time: '1:00 PM',
    priority: 2,
    color: AppColors.accentGreen,
    completed: true,
  ),
];

final _stats = [
  _StatItem(
    label: 'Due Today',
    value: '12',
    icon: Icons.style_outlined,
    color: AppColors.primary,
  ),
  _StatItem(
    label: 'Streak',
    value: '7',
    icon: Icons.local_fire_department_outlined,
    color: AppColors.accentOrange,
  ),
  _StatItem(
    label: 'Total Scans',
    value: '48',
    icon: Icons.document_scanner_outlined,
    color: AppColors.secondary,
  ),
  _StatItem(
    label: 'Mastery %',
    value: '72%',
    icon: Icons.emoji_events_outlined,
    color: AppColors.accentGreen,
  ),
];

// â”€â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

class _HomeScreenState extends State<HomeScreen> {
  // Reserved for future schedule tabs
  late final PageController _statsController;
  int _currentStat = 0;

  @override
  void initState() {
    super.initState();
    _statsController = PageController(viewportFraction: 0.72);
  }

  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // â”€â”€ Promo Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(
              child: _buildPromoBanner(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // â”€â”€ Stats Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(
              child: _buildStatsCarousel(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // â”€â”€ Section Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SliverToBoxAdapter(
              child: _buildSectionHeader('Your Schedule', 'See all'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // â”€â”€ Task List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildResponsiveTaskList(),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          // Menu button to open drawer
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(
                  Icons.menu,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Notification bell
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Toggle Tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€


  // â”€â”€â”€ Promo Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.primaryShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacityCompat(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AI FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Flexible(
                      child: Text(
                        'Ace Your Exams',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Flexible(
                      child: Text(
                        'Generate custom papers that target your weaknesses!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Try it now button
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Try it now',
                          style: AppTextStyles.buttonSM.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€ Stats Carousel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStatsCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _statsController,
              itemCount: _stats.length,
              onPageChanged: (index) => setState(() => _currentStat = index),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _statsController,
                  builder: (context, child) {
                    final page = _statsController.hasClients
                        ? (_statsController.page ?? _currentStat.toDouble())
                        : _currentStat.toDouble();
                    final delta = (page - index).abs().clamp(0.0, 1.0);
                    final scale = lerpDouble(1.0, 0.86, delta) ?? 1.0;
                    final blur = lerpDouble(0.0, 6.0, delta) ?? 0.0;
                    final opacity = lerpDouble(1.0, 0.6, delta) ?? 1.0;
                    final isActive = delta < 0.15;

                    return Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                            child: _buildStatCard(_stats[index], isActive: isActive),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildStatDots(),
        ],
      ),
    );
  }

  Widget _buildStatCard(_StatItem stat, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 18 : 14,
        vertical: isActive ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? stat.color.withOpacityCompat(0.6) : AppColors.border,
          width: isActive ? 1.4 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: stat.color.withOpacityCompat(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                ...AppColors.cardShadow,
              ]
            : AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isActive ? 44 : 38,
            height: isActive ? 44 : 38,
            decoration: BoxDecoration(
              color: stat.color.withOpacityCompat(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: stat.color, size: isActive ? 24 : 22),
          ),
          const SizedBox(height: 10),
          Text(
            stat.value,
            style: AppTextStyles.headingSM.copyWith(
              color: AppColors.textPrimary,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
              fontSize: isActive ? 20 : 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: AppTextStyles.labelSM.copyWith(
              color: AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_stats.length, (i) {
        final isActive = i == _currentStat;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  SliverPadding _buildResponsiveTaskList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.crossAxisExtent >= 720;
          if (!isWide) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildTaskCard(_mockTasks[i], i),
                ),
                childCount: _mockTasks.length,
              ),
            );
          }

          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildTaskCard(_mockTasks[i], i),
              childCount: _mockTasks.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.7,
            ),
          );
        },
      ),
    );
  }

  // â”€â”€â”€ Section Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.headingMD.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onSeeAllTap,
            child: Text(
              action,
              style: AppTextStyles.buttonSM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Task Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildTaskCard(_Task task, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
              // Priority indicator
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: task.color.withOpacityCompat(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.subject,
                          style: AppTextStyles.labelSM.copyWith(
                            color: task.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: AppTextStyles.bodyLG.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.time,
                          style: AppTextStyles.labelSM.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ...List.generate(
                          task.priority,
                          (i) => Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Checkbox
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: task.completed ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.completed ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€ Drawer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildDrawer() {
    final settings = AppSettingsScope.of(context);
    return Drawer(
      backgroundColor: AppColors.bgBase,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: CircleAvatar(
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
                backgroundColor: AppColors.bgCard,
              ),
            ),
            accountName: Text(
              'Mark Parker',
              style: AppTextStyles.headingSM.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            accountEmail: Text(
              'mark@peckpapers.com',
              style: AppTextStyles.bodySM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: AppColors.textPrimary),
                  title: Text(
                    'Profile',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.credit_card, color: AppColors.textPrimary),
                  title: Text(
                    'Subscription',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.dark_mode, color: AppColors.textPrimary),
                  title: Text(
                    'Dark Mode',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
                  ),
                  value: settings.isDark,
                  onChanged: (value) {
                    settings.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeThumbColor: AppColors.primary,
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.textPrimary),
                  title: Text(
                    'Settings',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: AppColors.error),
                  title: Text(
                    'Logout',
                    style: AppTextStyles.bodyMD.copyWith(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

