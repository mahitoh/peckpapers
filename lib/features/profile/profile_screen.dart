import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              onBack: () => Navigator.pop(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _ProfileBody(user: _users.first)),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 24, 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Profiles',
              style: AppTextStyles.headingMD.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final _RankedUser user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: user.color.withOpacityCompat(0.15),
                  child: Text(
                    user.initials,
                    style: AppTextStyles.headingMD.copyWith(color: user.color),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: AppTextStyles.headingMD.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withOpacityCompat(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Global Rank  #${user.rank}',
                    style: AppTextStyles.bodyMD.copyWith(
                      color: AppColors.violet,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(title: 'Study time', value: '4h 20m this week'),
          const SizedBox(height: 12),
          _InfoCard(title: 'Mastery', value: 'Top 2% worldwide'),
          const SizedBox(height: 12),
          _InfoCard(title: 'Streak', value: '18 days active'),
          const SizedBox(height: 12),
          _InfoCard(title: 'Cards learned', value: '210 total cards'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.labelSM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankedUser {
  const _RankedUser({
    required this.rank,
    required this.name,
    required this.email,
    required this.detail,
    required this.color,
    required this.initials,
  });

  final int rank;
  final String name;
  final String email;
  final String detail;
  final Color color;
  final String initials;
}

final _users = [
  _RankedUser(
    rank: 186,
    name: 'Mark Parker',
    email: 'mark@peckpapers.com',
    detail: 'Study time 4h 20m',
    color: AppColors.violet,
    initials: 'MP',
  ),
];
