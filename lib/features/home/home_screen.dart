// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/settings/app_settings_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/responsive_layout.dart';
import '../settings/settings_screen.dart';
import '../shell/placeholder_screen.dart';

// --- Models ---

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

final _mockTasks = [
  _Task(
    title: 'Calculus  Integration',
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

// --- Screen ---

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
  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      drawer: _buildDrawer(),
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
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(
                  Icons.menu_rounded,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
            title: Text(
              'PECKPAPERS',
              style: AppTextStyles.headingMD.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTopTab('For You', true),
                    _buildTopTab('Schedule', false),
                  ],
                ),
              ),
            ),
          ),

          // --- Pinned Promo ---
          SliverToBoxAdapter(child: _buildPromoBanner(rs)),

          // --- Feed ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildTweetCard(_mockTasks[i]),
              childCount: _mockTasks.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTopTab(String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 14),
          Text(
            label,
            style: AppTextStyles.bodyMDMedium.copyWith(
              color: active ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (active)
            Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(ResponsiveScale rs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 16,
        opacity: 0.1,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ace Your Exams',
                    style: AppTextStyles.headingMD.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generate custom papers that target your weaknesses!',
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ResponsiveScale rs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs.hPadding),
      child: Row(
        children: [
          _buildStatCard(
            'Cards',
            '12',
            Icons.style_rounded,
            AppColors.primary,
            rs,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Streak',
            '7',
            Icons.local_fire_department_rounded,
            AppColors.accentOrange,
            rs,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Expert',
            '72%',
            Icons.auto_awesome_rounded,
            AppColors.accentGreen,
            rs,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ResponsiveScale rs,
  ) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        borderRadius: 20,
        opacity: AppColors.isDark ? 0.05 : 0.03,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headingMD.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: rs.font(18, min: 16, max: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, ResponsiveScale rs) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs.hPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headingLG),
          TextButton(
            onPressed: widget.onSeeAllTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              action,
              style: AppTextStyles.buttonSM.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTweetCard(_Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar/Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: task.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              task.completed
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: task.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      task.subject,
                      style: AppTextStyles.bodyMDMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      ' ${task.time}',
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: AppTextStyles.bodyLG.copyWith(
                    color: AppColors.textPrimary,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Interaction bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTweetAction(Icons.chat_bubble_outline_rounded, '2'),
                    _buildTweetAction(Icons.repeat_rounded, '1'),
                    _buildTweetAction(
                      task.completed
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      task.completed ? '1' : '0',
                      color: task.completed ? AppColors.error : null,
                    ),
                    _buildTweetAction(Icons.share_outlined, ''),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTweetAction(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textTertiary),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSM.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDrawer() {
    final settings = AppSettingsScope.of(context);
    return Drawer(
      backgroundColor: AppColors.bgBase,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Twitter-style Header ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mark Parker',
                    style: AppTextStyles.headingMD.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '@mark_peck',
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDrawerStat('24', 'Documents'),
                      const SizedBox(width: 16),
                      _buildDrawerStat('1.2k', 'Flashcards'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerTile(
                    Icons.person_outline_rounded,
                    'Profile',
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Profile')));
                    },
                  ),
                  _buildDrawerTile(
                    Icons.list_alt_rounded,
                    'Study Lists',
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Study Lists')));
                    },
                  ),
                  _buildDrawerTile(
                    Icons.bookmark_border_rounded,
                    'Bookmarks',
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Bookmarks')));
                    },
                  ),
                  _buildDrawerTile(
                    Icons.credit_card_rounded,
                    'Subscription',
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Subscription')));
                    },
                  ),
                  const Divider(
                    height: 32,
                    thickness: 0.5,
                    indent: 24,
                    endIndent: 24,
                  ),
                  _buildDrawerTile(
                    Icons.settings_outlined,
                    'Settings & Privacy',
                    () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerTile(
                    Icons.help_outline_rounded,
                    'Help Center',
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Help Center')));
                    },
                  ),
                ],
              ),
            ),

            // Theme Toggle Bottom
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  Switch(
                    value: settings.isDark,
                    onChanged: (v) => settings.setThemeMode(
                      v ? ThemeMode.dark : ThemeMode.light,
                    ),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerStat(String count, String label) {
    return Row(
      children: [
        Text(
          count,
          style: AppTextStyles.bodyMDMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySM.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildDrawerTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isError = false,
  }) {
    final color = isError ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTextStyles.bodyMD.copyWith(color: color)),
      onTap: onTap,
    );
  }
}


