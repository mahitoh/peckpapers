// lib/features/shell/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peckpapers/features/liabrary/library_screen.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../scanner/scanner_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../analytics/analytics_screen.dart';

// Nav item model
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}


const _navItems = [
  _NavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_filled,
    label: 'Home',
  ),
  _NavItem(
    icon: Icons.search_rounded,
    activeIcon: Icons.manage_search_rounded,
    label: 'Library',
  ),
  _NavItem(
    icon: Icons.document_scanner_outlined,
    activeIcon: Icons.document_scanner_rounded,
    label: 'Scan',
  ),
  _NavItem(
    icon: Icons.style_outlined,
    activeIcon: Icons.style_rounded,
    label: 'Cards',
  ),
  _NavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Stats',
  ),
];

//  Shell 

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentTab = 0;

  // One animation controller per tab for indicator
  late List<AnimationController> _indicatorCtrls;
  late List<Animation<double>> _indicatorScales;

  // Page transition
  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;

  @override
  void initState() {
    super.initState();

    //  Tab indicator animations 
    _indicatorCtrls = List.generate(
      _navItems.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _indicatorScales = _indicatorCtrls
        .map(
          (ctrl) => Tween<double>(
            begin: 1.0,
            end: 1.18,
          ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack)),
        )
        .toList();

    // Activate first tab
    _indicatorCtrls[0].forward();

    //  Page transition 
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.forward();
  }

  @override
  void dispose() {
    for (final ctrl in _indicatorCtrls) {
      ctrl.dispose();
    }
    _pageCtrl.dispose();
    super.dispose();
  }

  //  Switch tab 

  void _switchTab(int index) {
    if (index == 2) {
      _openScanner();
      return;
    }
    if (index == _currentTab) return;

    HapticFeedback.selectionClick();
    _indicatorCtrls[_currentTab].reverse();
    setState(() => _currentTab = index);
    _indicatorCtrls[index].forward();
    _pageCtrl.reset();
    _pageCtrl.forward();
  }

  //  Open scanner 

  void _openScanner() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: ScannerScreen(
            onSaved: () => Navigator.of(context).pop(),
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  //  Build creen for index 

  Widget _buildScreen(int index) {
    return switch (index) {
      0 => HomeScreen(
        onScanTap: _openScanner,
        onDocTap: (_) => _switchTab(1),
        onSeeAllTap: () => _switchTab(1),
        onStatTap: () => _switchTab(4),
      ),
      1 => LibraryScreen(
        onDocumentTap: (_) => _switchTab(1),
        onScanTap: _openScanner,
      ),
      3 => const FlashcardsScreen(),
      4 => AnalyticsScreen(onBack: () => _switchTab(0)),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Match status bar to current theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppColors.isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: AppColors.bgSurface,
        systemNavigationBarIconBrightness: AppColors.isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      extendBody: true, // content goes under nav bar
      body: Stack(
        children: [
          // Screens kept alive 
          // Use IndexedStack so all screens stay mounted
          // (scroll positions, state preserved when switching tabs)
          IndexedStack(
            index: _currentTab == 2 ? 0 : _currentTab,
            children: [
              _KeepAliveScreen(child: _buildScreen(0)),
              _KeepAliveScreen(child: _buildScreen(1)),
              const SizedBox.shrink(), // scanner index
              _KeepAliveScreen(child: _buildScreen(3)),
              _KeepAliveScreen(child: _buildScreen(4)),
            ],
          ),

          // Page fade/slide overlay
          Positioned.fill(
            child: IgnorePointer(
              child: FadeTransition(
                opacity: ReverseAnimation(_pageFade),
                child: Container(color: AppColors.bgBase),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _PeckNavBar(
        currentIndex: _currentTab,
        items: _navItems,
        scales: _indicatorScales,
        onTap: _switchTab,
      ),
    );
  }
}

// Keep Alive Screen 
// Wraps each screen so IndexedStack never rebuilds them

class _KeepAliveScreen extends StatefulWidget {
  const _KeepAliveScreen({required this.child});
  final Widget child;

  @override
  State<_KeepAliveScreen> createState() => _KeepAliveScreenState();
}

class _KeepAliveScreenState extends State<_KeepAliveScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// Custom Nav Ba

class _PeckNavBar extends StatelessWidget {
  const _PeckNavBar({
    required this.currentIndex,
    required this.items,
    required this.scales,
    required this.onTap,
  });
  final int currentIndex;
  final List<_NavItem> items;
  final List<Animation<double>> scales;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56, // Slightly shorter, like standard bottom navs
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isActive: isActive,
                  scale: scales[i],
                  onTap: () => onTap(i),
                  isSpecial: false, // all icons styled identically
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

//Nav Bar Item

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.scale,
    required this.onTap,
    this.isSpecial = false,
  });
  final _NavItem item;
  final bool isActive;
  final Animation<double> scale;
  final VoidCallback onTap;
  final bool isSpecial;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: scale,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              size: 28, // Twitter uses larger icons with no text
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}



