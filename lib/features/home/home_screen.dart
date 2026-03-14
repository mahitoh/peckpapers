// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// ─── Models ─────────────────────────────────────────────────────────────────

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

const _mockTasks = [
  _Task(
    title: 'Calculus — Integration',
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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0 = Today, 1 = Calendar
  bool _isDarkMode = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Promo Banner ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildPromoBanner()),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Stats Row ───────────────────────────────────────────
            SliverToBoxAdapter(child: _buildStatsRow()),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Section Header ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionHeader('Your Schedule', 'See all'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Task List ────────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildTaskCard(_mockTasks[i], i),
                childCount: _mockTasks.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

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
                child: Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
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

  // ─── Toggle Tabs ───────────────────────────────────────────────────────────

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabButton('Today', 0)),
            Expanded(child: _buildTabButton('Calendar', 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.buttonSM.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Promo Banner ────────────────────────────────────────────────────────────

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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

  // ─── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            'Due Today',
            '12',
            Icons.style_outlined,
            AppColors.primary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Streak',
            '7',
            Icons.local_fire_department_outlined,
            AppColors.accentOrange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Scans',
            '48',
            Icons.document_scanner_outlined,
            AppColors.secondary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Mastery %',
            '72%',
            Icons.emoji_events_outlined,
            AppColors.accentGreen,
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
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headingSM.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ────────────────────────────────────────────────────────

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

  // ─── Task Card ─────────────────────────────────────────────────────────────

  Widget _buildTaskCard(_Task task, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Container(
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
                            color: task.color.withOpacity(0.3),
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
                  color: task.completed
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: task.completed
                        ? AppColors.primary
                        : AppColors.border,
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
      ),
    );
  }

  // ─── Drawer ─────────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.bgBase,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.bgSurface),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: CircleAvatar(
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
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
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(
                    'Subscription',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SwitchListTile(
                  secondary: Icon(
                    Icons.dark_mode,
                    color: AppColors.textPrimary,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    // TODO: Implement actual theme toggle
                  },
                  activeThumbColor: AppColors.primary,
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.textPrimary),
                  title: Text(
                    'Settings',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: AppColors.error),
                  title: Text(
                    'Logout',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.error,
                    ),
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
