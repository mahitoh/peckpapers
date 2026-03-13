// lib/features/library/library_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/glow_container.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

class _Document {
  const _Document({
    required this.id,
    required this.title,
    required this.subject,
    required this.pageCount,
    required this.cardCount,
    required this.progress,
    required this.color,
    required this.icon,
    required this.dateAdded,
    this.isFavourite = false,
  });
  final String id;
  final String title;
  final String subject;
  final int pageCount;
  final int cardCount;
  final double progress;
  final Color color;
  final IconData icon;
  final String dateAdded;
  final bool isFavourite;
}

const _allDocs = [
  _Document(
    id: '1',
    title: 'Calculus — Integration by Parts',
    subject: 'Mathematics',
    pageCount: 4,
    cardCount: 24,
    progress: 0.72,
    color: AppColors.amber,
    icon: Icons.functions_rounded,
    dateAdded: '2 days ago',
    isFavourite: true,
  ),
  _Document(
    id: '2',
    title: 'Organic Chemistry Part 2',
    subject: 'Chemistry',
    pageCount: 6,
    cardCount: 38,
    progress: 0.45,
    color: AppColors.error,
    icon: Icons.science_rounded,
    dateAdded: '3 days ago',
  ),
  _Document(
    id: '3',
    title: 'World War II — Causes & Effects',
    subject: 'History',
    pageCount: 8,
    cardCount: 16,
    progress: 0.91,
    color: AppColors.success,
    icon: Icons.history_edu_rounded,
    dateAdded: '5 days ago',
    isFavourite: true,
  ),
  _Document(
    id: '4',
    title: 'Newton\'s Laws of Motion',
    subject: 'Physics',
    pageCount: 3,
    cardCount: 20,
    progress: 0.30,
    color: AppColors.violet,
    icon: Icons.bolt_rounded,
    dateAdded: '1 week ago',
  ),
  _Document(
    id: '5',
    title: 'Supply & Demand Curves',
    subject: 'Economics',
    pageCount: 5,
    cardCount: 14,
    progress: 0.60,
    color: AppColors.warning,
    icon: Icons.trending_up_rounded,
    dateAdded: '1 week ago',
  ),
  _Document(
    id: '6',
    title: 'Cell Biology — Mitosis',
    subject: 'Biology',
    pageCount: 7,
    cardCount: 32,
    progress: 0.15,
    color: Color(0xFF3ECF8E),
    icon: Icons.biotech_rounded,
    dateAdded: '2 weeks ago',
  ),
];

const _subjects = [
  'All',
  'Mathematics',
  'Physics',
  'Chemistry',
  'History',
  'Economics',
  'Biology',
];

enum _SortOption { recent, title, progress, cardCount }

enum _ViewMode { list, grid }

// ─── Screen ───────────────────────────────────────────────────────────────────

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.onDocumentTap,
    this.onBack,
    this.onScanTap,
  });

  final ValueChanged<_Document>? onDocumentTap;
  final VoidCallback? onBack;
  final VoidCallback? onScanTap;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  // Search
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchActive = false;
  String _query = '';

  // Filters
  String _selectedSubject = 'All';
  _SortOption _sortOption = _SortOption.recent;
  _ViewMode _viewMode = _ViewMode.list;

  // Favourites toggle
  bool _showFavouritesOnly = false;

  // List entrance animation
  late AnimationController _listCtrl;

  // Search bar expand animation
  late AnimationController _searchCtrl2;
  late Animation<double> _searchWidth;

  @override
  void initState() {
    super.initState();

    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _searchCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchWidth = CurvedAnimation(
      parent: _searchCtrl2,
      curve: Curves.easeInOutCubic,
    );

    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _listCtrl.dispose();
    _searchCtrl2.dispose();
    super.dispose();
  }

  // ── Activate / deactivate search ─────────────────────────────────────────────

  void _activateSearch() {
    setState(() => _searchActive = true);
    _searchCtrl2.forward();
    Future.delayed(
      const Duration(milliseconds: 150),
      () => _searchFocus.requestFocus(),
    );
  }

  void _deactivateSearch() {
    _searchFocus.unfocus();
    _searchCtrl2.reverse();
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) {
        setState(() {
          _searchActive = false;
          _query = '';
          _searchCtrl.clear();
        });
      }
    });
  }

  // ── Filter + sort docs ────────────────────────────────────────────────────────

  List<_Document> get _filtered {
    var docs = List<_Document>.from(_allDocs);

    // Subject filter
    if (_selectedSubject != 'All') {
      docs = docs.where((d) => d.subject == _selectedSubject).toList();
    }

    // Favourites filter
    if (_showFavouritesOnly) {
      docs = docs.where((d) => d.isFavourite).toList();
    }

    // Search query
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      docs = docs
          .where(
            (d) =>
                d.title.toLowerCase().contains(q) ||
                d.subject.toLowerCase().contains(q),
          )
          .toList();
    }

    // Sort
    docs.sort(
      (a, b) => switch (_sortOption) {
        _SortOption.recent => 0,
        _SortOption.title => a.title.compareTo(b.title),
        _SortOption.progress => b.progress.compareTo(a.progress),
        _SortOption.cardCount => b.cardCount.compareTo(a.cardCount),
      },
    );

    return docs;
  }

  // ── Sort sheet ────────────────────────────────────────────────────────────────

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        selected: _sortOption,
        onSelect: (opt) {
          setState(() => _sortOption = opt);
          Navigator.pop(context);
          _refreshList();
        },
      ),
    );
  }

  void _refreshList() {
    _listCtrl.reset();
    _listCtrl.forward();
  }

  // ── Delete doc ────────────────────────────────────────────────────────────────

  void _deleteDoc(_Document doc) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${doc.title}" removed',
          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textPrimary),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.amber,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = _filtered;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _LibraryHeader(
              searchActive: _searchActive,
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              searchWidthAnim: _searchWidth,
              onSearchTap: _activateSearch,
              onSearchClose: _deactivateSearch,
              viewMode: _viewMode,
              onViewToggle: () => setState(() {
                _viewMode = _viewMode == _ViewMode.list
                    ? _ViewMode.grid
                    : _ViewMode.list;
                _refreshList();
              }),
              onSortTap: _showSortSheet,
              onBack: widget.onBack,
              showFavourites: _showFavouritesOnly,
              onFavouriteToggle: () => setState(() {
                _showFavouritesOnly = !_showFavouritesOnly;
                _refreshList();
              }),
            ),
          ),

          // ── Subject filter chips ─────────────────────────────
          SliverToBoxAdapter(
            child: _SubjectChips(
              selected: _selectedSubject,
              onSelect: (s) {
                setState(() => _selectedSubject = s);
                _refreshList();
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Result count ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Text(
                    '${docs.length} document${docs.length != 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMD,
                  ),
                  if (_showFavouritesOnly) ...[
                    const SizedBox(width: 8),
                    PeckBadge(
                      label: 'Favourites',
                      color: AppColors.amber,
                      style: BadgeStyle.subtle,
                      icon: const Icon(Icons.star_rounded),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Document list / grid ─────────────────────────────
          if (docs.isEmpty)
            SliverToBoxAdapter(child: _EmptyState(onScan: widget.onScanTap))
          else if (_viewMode == _ViewMode.list)
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final delay = i * 0.07;
                final fade = CurvedAnimation(
                  parent: _listCtrl,
                  curve: Interval(
                    delay.clamp(0.0, 0.8),
                    (delay + 0.4).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                );
                final slide =
                    Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _listCtrl,
                        curve: Interval(
                          delay.clamp(0.0, 0.8),
                          (delay + 0.4).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    );

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                  child: FadeTransition(
                    opacity: fade,
                    child: SlideTransition(
                      position: slide,
                      child: _SwipableDocRow(
                        doc: docs[i],
                        onTap: () => widget.onDocumentTap?.call(docs[i]),
                        onDelete: () => _deleteDoc(docs[i]),
                        onFav: () => setState(() {}),
                      ),
                    ),
                  ),
                );
              }, childCount: docs.length),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  final delay = i * 0.08;
                  final fade = CurvedAnimation(
                    parent: _listCtrl,
                    curve: Interval(
                      delay.clamp(0.0, 0.7),
                      (delay + 0.4).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  );
                  return FadeTransition(
                    opacity: fade,
                    child: _DocGridCard(
                      doc: docs[i],
                      onTap: () => widget.onDocumentTap?.call(docs[i]),
                    ),
                  );
                }, childCount: docs.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── FAB ─────────────────────────────────────────────────
      floatingActionButton: _ScanFab(onTap: widget.onScanTap),
    );
  }
}

// ─── Library Header ───────────────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.searchActive,
    required this.searchCtrl,
    required this.searchFocus,
    required this.searchWidthAnim,
    required this.onSearchTap,
    required this.onSearchClose,
    required this.viewMode,
    required this.onViewToggle,
    required this.onSortTap,
    required this.showFavourites,
    required this.onFavouriteToggle,
    this.onBack,
  });

  final bool searchActive;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final Animation<double> searchWidthAnim;
  final VoidCallback onSearchTap;
  final VoidCallback onSearchClose;
  final _ViewMode viewMode;
  final VoidCallback onViewToggle;
  final VoidCallback onSortTap;
  final bool showFavourites;
  final VoidCallback onFavouriteToggle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Back button
                if (!searchActive)
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.pop(context),
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

                if (!searchActive) const SizedBox(width: 14),

                // Title OR search bar
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: searchActive
                      ? SizedBox(
                          key: const ValueKey('search'),
                          width: screenW - 40 - 16 - 44,
                          child: _SearchField(
                            ctrl: searchCtrl,
                            focus: searchFocus,
                          ),
                        )
                      : Expanded(
                          key: const ValueKey('title'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Notes', style: AppTextStyles.bodyMD),
                              Text('Library', style: AppTextStyles.headingXL),
                            ],
                          ),
                        ),
                ),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    if (!searchActive)
                      _HeaderBtn(
                        icon: Icons.search_rounded,
                        onTap: onSearchTap,
                      ),
                    if (searchActive)
                      _HeaderBtn(
                        icon: Icons.close_rounded,
                        onTap: onSearchClose,
                      ),
                    const SizedBox(width: 8),
                    _HeaderBtn(
                      icon: showFavourites
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      onTap: onFavouriteToggle,
                      isActive: showFavourites,
                      activeColor: AppColors.amber,
                    ),
                    const SizedBox(width: 8),
                    _HeaderBtn(icon: Icons.sort_rounded, onTap: onSortTap),
                    const SizedBox(width: 8),
                    _HeaderBtn(
                      icon: viewMode == _ViewMode.list
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                      onTap: onViewToggle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header Button ────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.activeColor = AppColors.amber,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: isActive ? activeColor : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Search Field ─────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.ctrl, required this.focus});
  final TextEditingController ctrl;
  final FocusNode focus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.amber, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              style: AppTextStyles.bodyMDMedium,
              decoration: const InputDecoration(
                hintText: 'Search documents…',
                border: InputBorder.none,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subject Chips ────────────────────────────────────────────────────────────

class _SubjectChips extends StatelessWidget {
  const _SubjectChips({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = _subjects[i];
          final isSelected = s == selected;
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.amber : AppColors.bgCard,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppColors.amber : AppColors.border,
                ),
                boxShadow: isSelected ? AppColors.amberShadow : [],
              ),
              child: Text(
                s,
                style: AppTextStyles.labelLG.copyWith(
                  color: isSelected
                      ? AppColors.textInverse
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Swipable Doc Row ─────────────────────────────────────────────────────────

class _SwipableDocRow extends StatefulWidget {
  const _SwipableDocRow({
    required this.doc,
    required this.onTap,
    required this.onDelete,
    required this.onFav,
  });
  final _Document doc;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFav;

  @override
  State<_SwipableDocRow> createState() => _SwipableDocRowState();
}

class _SwipableDocRowState extends State<_SwipableDocRow> {
  double _dragX = 0;
  bool _revealed = false;

  static const _threshold = 72.0;

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dx > 0 && _dragX >= 0) return; // no right swipe
    setState(() {
      _dragX = (_dragX + d.delta.dx).clamp(-120.0, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragX.abs() > _threshold) {
      setState(() {
        _dragX = -96;
        _revealed = true;
      });
    } else {
      _snap();
    }
  }

  void _snap() {
    setState(() {
      _dragX = 0;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _revealed ? _snap : null,
      child: Stack(
        children: [
          // ── Action buttons (behind) ────────────────────────
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Favourite
                _SwipeAction(
                  icon: widget.doc.isFavourite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.amber,
                  onTap: () {
                    _snap();
                    widget.onFav();
                  },
                  width: 42,
                ),
                const SizedBox(width: 8),
                // Delete
                _SwipeAction(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.error,
                  onTap: () {
                    _snap();
                    widget.onDelete();
                  },
                  width: 42,
                ),
              ],
            ),
          ),

          // ── Card (slides left) ────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragX, 0, 0),
            child: _DocListCard(doc: widget.doc, onTap: widget.onTap),
          ),
        ],
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.width,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ─── Doc List Card ────────────────────────────────────────────────────────────

class _DocListCard extends StatelessWidget {
  const _DocListCard({required this.doc, required this.onTap});
  final _Document doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PeckCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: doc.color.withOpacity(0.18),
      child: Row(
        children: [
          // Icon
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

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.title,
                        style: AppTextStyles.headingSM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (doc.isFavourite)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.amber,
                          size: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    PeckBadge(
                      label: doc.subject,
                      color: doc.color,
                      style: BadgeStyle.subtle,
                    ),
                    const SizedBox(width: 8),
                    Text(doc.dateAdded, style: AppTextStyles.labelMD),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: Stack(
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
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(doc.progress * 100).toInt()}%',
                      style: AppTextStyles.labelLG.copyWith(color: doc.color),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${doc.cardCount}',
                style: AppTextStyles.headingSM.copyWith(color: doc.color),
              ),
              Text('cards', style: AppTextStyles.labelMD),
              const SizedBox(height: 8),
              Text('${doc.pageCount}p', style: AppTextStyles.labelMD),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Doc Grid Card ────────────────────────────────────────────────────────────

class _DocGridCard extends StatelessWidget {
  const _DocGridCard({required this.doc, required this.onTap});
  final _Document doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PeckCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: doc.color.withOpacity(0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + favourite row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: doc.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(doc.icon, color: doc.color, size: 22),
              ),
              if (doc.isFavourite)
                Icon(Icons.star_rounded, color: AppColors.amber, size: 16),
            ],
          ),

          const SizedBox(height: 14),

          // Title
          Text(
            doc.title,
            style: AppTextStyles.headingSM,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Subject badge
          PeckBadge(
            label: doc.subject,
            color: doc.color,
            style: BadgeStyle.subtle,
          ),

          const Spacer(),

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
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(doc.progress * 100).toInt()}%',
                style: AppTextStyles.labelLG.copyWith(color: doc.color),
              ),
              Text('${doc.cardCount} cards', style: AppTextStyles.labelMD),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onScan});
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Column(
        children: [
          GlowContainer(
            glowColor: AppColors.amber,
            glowRadius: 40,
            glowOpacity: 0.2,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: AppColors.textTertiary,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Nothing here yet', style: AppTextStyles.headingMD),
          const SizedBox(height: 8),
          Text(
            'Scan your first notes to get started.',
            style: AppTextStyles.bodyMD,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onScan,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.scannerGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.amberShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scan Notes',
                    style: AppTextStyles.buttonMD.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sort Sheet ───────────────────────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected, required this.onSelect});
  final _SortOption selected;
  final ValueChanged<_SortOption> onSelect;

  static const _options = [
    (
      label: 'Most Recent',
      icon: Icons.access_time_rounded,
      opt: _SortOption.recent,
    ),
    (
      label: 'Title A–Z',
      icon: Icons.sort_by_alpha_rounded,
      opt: _SortOption.title,
    ),
    (
      label: 'Most Progress',
      icon: Icons.trending_up_rounded,
      opt: _SortOption.progress,
    ),
    (
      label: 'Most Cards',
      icon: Icons.style_rounded,
      opt: _SortOption.cardCount,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('Sort by', style: AppTextStyles.headingMD),
          const SizedBox(height: 16),

          ..._options.map((o) {
            final isSelected = o.opt == selected;
            return GestureDetector(
              onTap: () => onSelect(o.opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.amberDim : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.amber.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      o.icon,
                      color: isSelected
                          ? AppColors.amber
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      o.label,
                      style: AppTextStyles.bodyMDMedium.copyWith(
                        color: isSelected
                            ? AppColors.amber
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_rounded,
                        color: AppColors.amber,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Scan FAB ─────────────────────────────────────────────────────────────────

class _ScanFab extends StatefulWidget {
  const _ScanFab({this.onTap});
  final VoidCallback? onTap;

  @override
  State<_ScanFab> createState() => _ScanFabState();
}

class _ScanFabState extends State<_ScanFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: widget.onTap,
        child: GlowContainer(
          glowColor: AppColors.amber,
          glowRadius: 28,
          glowOpacity: 0.4,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.scannerGradient,
              shape: BoxShape.circle,
              boxShadow: AppColors.amberShadow,
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
