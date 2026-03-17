// lib/features/flashcards/flashcards_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_button.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/glow_container.dart';
import '../../core/flashcards/flashcard_models.dart';
import '../../core/flashcards/flashcard_repository.dart';
import '../../core/flashcards/local_flashcard_repository.dart';
import '../../core/flashcards/srs_scheduler.dart';
import '../../core/services/analytics_service.dart';
import '../../core/widgets/peck_card.dart';
import '../../core/ai/ai_models.dart' as ai_models;
import '../../core/quiz/local_quiz_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/ai/offline_ai_service.dart';
import '../../core/services/library_service.dart';
import '../quiz/quiz_screen.dart' as quiz_screen;

// â”€â”€â”€ Data model â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FlashcardData {
  const FlashcardData({
    required this.id,
    required this.question,
    required this.answer,
    required this.subject,
    this.hint,
    this.mastery = 0,
  });

  final String id;
  final String question;
  final String answer;
  final String subject;
  final String? hint;
  final int mastery; // 0â€“5

  FlashcardData copyWith({int? mastery}) {
    return FlashcardData(
      id: id,
      question: question,
      answer: answer,
      subject: subject,
      hint: hint,
      mastery: mastery ?? this.mastery,
    );
  }
}



// â”€â”€â”€ Rating config â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Rating {
  const _Rating({
    required this.label,
    required this.emoji,
    required this.color,
    required this.quality, // SM-2: 1=hard, 3=good, 5=easy
  });
  final String label;
  final String emoji;
  final Color color;
  final int quality;
}

final _ratings = [
  _Rating(label: 'Hard', emoji: '😞', color: AppColors.error, quality: 1),
  _Rating(label: 'Good', emoji: '🙂', color: AppColors.warning, quality: 3),
  _Rating(label: 'Easy', emoji: '🚀', color: AppColors.success, quality: 5),
];

// â”€â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    this.deck,
    this.deckTitle,
    this.docId,
    this.onFinished,
    this.onBack,
    this.onQuizTap,
    this.repository,
    this.scheduler,
  });

  final List<FlashcardData>? deck;
  final String? deckTitle;
  final String? docId;
  final VoidCallback? onFinished;
  final VoidCallback? onBack;
  final VoidCallback? onQuizTap;
  final FlashcardRepository? repository;
  final SrsScheduler? scheduler;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {
  int _index = 0;
  bool _flipped = false;
  List<FlashcardData> _deck = [];
  late final SrsScheduler _scheduler;
  late DateTime _startTime;
  List<FlashcardDeck> _allDecks = [];
  bool _loading = false;
  String? _selectedDocId;

  // Card flip
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  // Card entrance (slide in from right or left)
  late AnimationController _enterCtrl;
  late Animation<Offset> _enterAnim;
  late Animation<double> _enterFade;

  // Rating buttons slide up
  late AnimationController _ratingCtrl;
  late Animation<Offset> _ratingSlide;
  late Animation<double> _ratingFade;

  // Swipe drag offset
  double _dragDx = 0;

  FlashcardData get _current => _deck[_index];
  bool get _isLast => _index == _deck.length - 1;

  @override
  void initState() {
    super.initState();
    _scheduler = widget.scheduler ?? const SrsScheduler();
    _startTime = DateTime.now();

    if (widget.deck != null) {
      _deck = List<FlashcardData>.from(widget.deck!);
    } else {
      _loadDecks();
    }

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _flipAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic));

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterAnim = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _ratingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _ratingFade = CurvedAnimation(parent: _ratingCtrl, curve: Curves.easeOut);
    _ratingSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ratingCtrl, curve: Curves.easeOutCubic));

    _enterCtrl.forward();
  }

  @override
  void dispose() { _logStudyTime();
    _flipCtrl.dispose();
    _enterCtrl.dispose();
    _ratingCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Flip card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _flip() {
    HapticFeedback.lightImpact();
    if (_flipped) {
      _flipCtrl.reverse();
      _ratingCtrl.reverse();
    } else {
      _flipCtrl.forward();
      _ratingCtrl.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  // â”€â”€ Rate & advance â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _rate(int quality) {
    HapticFeedback.mediumImpact();
    final last = _isLast;
    _updateMastery(quality);
    if (last) {
      setState(() {});
    }
    _recordReview(quality);

    if (last) {
      widget.onFinished?.call();
      _showFinishSheet();
      return;
    }

    setState(() {
      _flipped = false;
      _index++;
    });
    _enterCtrl.forward(from: 0);
  }

  Future<void> _loadDecks() async {
    setState(() => _loading = true);
    final decks = await LocalFlashcardRepository.instance.fetchDecks();
    if (mounted) {
      setState(() {
        _allDecks = decks;
        _loading = false;
      });
    }
  }

  void _selectDeck(FlashcardDeck deck) {
    setState(() {
      _deck = deck.cards.map((c) => FlashcardData(
        id: c.id,
        question: c.question,
        answer: c.answer,
        subject: c.subject,
        hint: c.hint,
      )).toList();
      _index = 0;
      _selectedDocId = deck.docId;
    });
    _flipCtrl.reset();
    _ratingCtrl.reset();
    _enterCtrl.reset();
    _enterCtrl.forward();
  }


  Future<void> _deleteDeck(FlashcardDeck deck) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Delete deck?', style: AppTextStyles.headingSM),
        content: Text('This will permanently delete all cards in this deck.', style: AppTextStyles.bodyMD),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final allDecks = await LocalFlashcardRepository.instance.fetchDecks();
    final remaining = allDecks.where((d) => d.id != deck.id).toList();
    // Clear and re-save remaining decks
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('flashcard_decks');
    for (final d in remaining) await LocalFlashcardRepository.instance.saveDeck(d);
    await _loadDecks();
  }

  Future<void> _regenerateDeck(FlashcardDeck deck) async {
    if (deck.docId == null) return;
    final docs = await LibraryService.instance.getDocuments();
    final doc = docs.where((d) => d.id == deck.docId).firstOrNull;
    if (doc == null || (doc.textContent ?? '').isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No source text found for this deck.')));
      return;
    }
    if (mounted) setState(() => _loading = true);
    try {
      final aiCards = await OfflineAiService.instance.generateFlashcards(doc.textContent!, subject: doc.subject, count: 15);
      var idx = 0;
      final mappedCards = aiCards.map((c) => Flashcard(id: 'card_regen_${DateTime.now().microsecondsSinceEpoch}_${idx++}', question: c.question, answer: c.answer, subject: c.subject ?? doc.subject, createdAt: DateTime.now())).toList();
      final newDeck = FlashcardDeck(id: deck.id, title: deck.title, cards: mappedCards, createdAt: deck.createdAt, docId: deck.docId);
      await LocalFlashcardRepository.instance.saveDeck(newDeck);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cards regenerated!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
    await _loadDecks();
  }

  void _updateMastery(int quality) {
    final current = _current;
    final delta = quality >= 4 ? 1 : (quality <= 2 ? -1 : 0);
    final nextMastery = (current.mastery + delta).clamp(0, 5);
    _deck[_index] = current.copyWith(mastery: nextMastery);
  }

  void _logStudyTime() {
    final duration = DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    if (minutes > 0) {
      AnalyticsService.instance.logStudyTime(minutes);
    } else if (duration.inSeconds > 30) {
      // Log at least 1 minute if they spent more than 30 seconds
      AnalyticsService.instance.logStudyTime(1);
    }
  }

  Future<void> _recordReview(int quality) async {
    final repo = widget.repository;
    if (repo == null) return;
    final card = _current;
    final logs = await repo.fetchLogsForCard(card.id);
    logs.sort((a, b) => a.reviewedAt.compareTo(b.reviewedAt));
    final previous = logs.isEmpty ? null : logs.last;
    final log = _scheduler.schedule(
      cardId: card.id,
      quality: quality,
      now: DateTime.now(),
      previous: previous,
    );
    await repo.saveReviewLog(log);
  }

  // â”€â”€ Swipe gesture â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragDx = d.primaryDelta ?? 0);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    setState(() => _dragDx = 0);

    if (velocity > 600 && _index > 0) {
      // Swipe right â€” go back
      setState(() {
        _flipped = false;
        _index--;
      });
      _flipCtrl.reset();
      _ratingCtrl.reset();
    } else if (velocity < -600) {
      _flip();
    }
  }

  // â”€â”€ Finish sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showFinishSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FinishSheet(
        total: _deck.length,
        deckTitle: widget.deckTitle,
        docId: widget.docId ?? _selectedDocId,
        onRestart: () {
          Navigator.pop(context);
          setState(() {
            _index = 0;
            _flipped = false;
          });
          _flipCtrl.reset();
          _ratingCtrl.reset();
          _enterCtrl.reset();
          _enterCtrl.forward();
        },
        onQuiz: () {
          Navigator.pop(context);
          widget.onQuizTap?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show lobby (deck picker) when no deck is loaded yet
    if (_deck.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgBase,
        appBar: AppBar(
          backgroundColor: AppColors.bgBase,
          elevation: 0,
          title: Text('Flashcard Decks', style: AppTextStyles.headingMD),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: widget.onBack ?? () => Navigator.pop(context),
          ),
        ),
        body: _loading
            ? _CardShimmer()
            : _allDecks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.style_outlined, size: 80, color: AppColors.border),
                          const SizedBox(height: 24),
                          Text('No decks found', style: AppTextStyles.headingMD),
                          const SizedBox(height: 8),
                          Text(
                            'Go to your library and select a document to generate flashcards.',
                            style: AppTextStyles.bodyMD,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _allDecks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final d = _allDecks[i];
                      return PeckCard(
                        onTap: () => _selectDeck(d),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.amber.withOpacityCompat(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.style_rounded, color: AppColors.amber),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.title, style: AppTextStyles.headingSM),
                                  const SizedBox(height: 4),
                                  Text('${d.cards.length} cards', style: AppTextStyles.bodySM),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(icon: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary, size: 20), onSelected: (v) { if (v == 'delete') _deleteDeck(d); else if (v == 'regen') _regenerateDeck(d); }, itemBuilder: (_) => [const PopupMenuItem(value: 'regen', child: Row(children: [Icon(Icons.refresh_rounded, size: 18), SizedBox(width: 8), Text('Regenerate cards')])), const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete deck', style: TextStyle(color: Colors.red))]))])
                          ],
                        ),
                      );
                    },
                  ),
      );
    }

    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // â”€â”€ Top bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _TopBar(
              title: widget.deckTitle,
              onBack: widget.onBack ?? () { if (Navigator.canPop(context)) Navigator.pop(context); },
              onMore: () {},
            ),

            const SizedBox(height: 8),

            // â”€â”€ Progress row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _ProgressRow(current: _index + 1, total: _deck.length),

            const SizedBox(height: 32),

            // â”€â”€ Card area â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Center(
                  child: FadeTransition(
                    opacity: _enterFade,
                    child: SlideTransition(
                      position: _enterAnim,
                      child: _FlipCard(
                        card: _current,
                        flipAnim: _flipAnim,
                        dragDx: _dragDx,
                        width: size.width - 48,
                        height: (size.width - 48) * 1.22,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // â”€â”€ Tap hint â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            AnimatedOpacity(
              opacity: _flipped ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap card to reveal answer',
                    style: AppTextStyles.labelLG,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // â”€â”€ Rating buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            SlideTransition(
              position: _ratingSlide,
              child: FadeTransition(
                opacity: _ratingFade,
                child: _RatingRow(onRate: _rate),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Top Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onMore,
  });
  final String? title;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _NavBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flashcards',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(title ?? '', style: AppTextStyles.headingLG),
              ],
            ),
          ),
          PeckBadge(
            label: 'SRS',
            color: AppColors.violet,
            style: BadgeStyle.subtle,
            icon: const Icon(Icons.psychology_rounded),
          ),
          const SizedBox(width: 8),
          _NavBtn(icon: Icons.more_horiz_rounded, onTap: onMore),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    ),
  );
}

// â”€â”€â”€ Progress Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = current / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current of $total',
                style: AppTextStyles.bodyMDMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.bodyMDMedium.copyWith(
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Segmented progress dots
          Row(
            children: List.generate(total, (i) {
              final done = i < current - 1;
              final active = i == current - 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.success
                          : active
                          ? AppColors.amber
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.amber.withOpacityCompat(0.5),
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
        ],
      ),
    );
  }
}

// â”€â”€â”€ Flip Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.card,
    required this.flipAnim,
    required this.dragDx,
    required this.width,
    required this.height,
  });

  final FlashcardData card;
  final Animation<double> flipAnim;
  final double dragDx;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flipAnim,
      builder: (_, _) {
        final angle = flipAnim.value * math.pi;
        final isBack = angle > math.pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // perspective
            ..rotateY(angle)
            ..rotateZ(dragDx * 0.003),
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _CardFace(
                    card: card,
                    isFront: false,
                    width: width,
                    height: height,
                  ),
                )
              : _CardFace(
                  card: card,
                  isFront: true,
                  width: width,
                  height: height,
                ),
        );
      },
    );
  }
}

// â”€â”€â”€ Card Face â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.isFront,
    required this.width,
    required this.height,
  });

  final FlashcardData card;
  final bool isFront;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GlowContainer(
      glowColor: isFront ? AppColors.amber : AppColors.violet,
      glowRadius: 60,
      glowOpacity: 0.18,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: isFront
              ? AppColors.cardGradient
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.violet.withOpacityCompat(0.18),
                    AppColors.bgCard,
                    AppColors.bgCard,
                  ],
                ),
          border: Border.all(
            color: isFront
                ? AppColors.border
                : AppColors.violet.withOpacityCompat(0.35),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isFront ? AppColors.amber : AppColors.violet)
                      .withOpacityCompat(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isFront ? AppColors.amber : AppColors.violet)
                      .withOpacityCompat(0.04),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row â€” label + subject chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PeckBadge(
                        label: isFront ? 'QUESTION' : 'ANSWER',
                        color: isFront ? AppColors.amber : AppColors.violet,
                        style: BadgeStyle.subtle,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          card.subject,
                          style: AppTextStyles.labelMD.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Question / Answer text
                  isFront ? _QuestionSide(card: card) : _AnswerSide(card: card),

                  const Spacer(),

                  // Bottom row â€” mastery dots
                  if (isFront) _MasteryRow(mastery: card.mastery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Question Side â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _QuestionSide extends StatelessWidget {
  const _QuestionSide({required this.card});
  final FlashcardData card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(card.question, style: AppTextStyles.flashcardQuestion),
        if (card.hint != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amberDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.amber.withOpacityCompat(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.amber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.hint!,
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.amber.withOpacityCompat(0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// â”€â”€â”€ Answer Side â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AnswerSide extends StatelessWidget {
  const _AnswerSide({required this.card});
  final FlashcardData card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider line
        Container(
          width: 48,
          height: 3,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: AppColors.violetGradient,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withOpacityCompat(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        Text(
          card.answer,
          style: AppTextStyles.bodyLG.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€ Mastery Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MasteryRow extends StatelessWidget {
  const _MasteryRow({required this.mastery});
  final int mastery; // 0â€“5

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Mastery', style: AppTextStyles.labelMD),
        const SizedBox(width: 10),
        ...List.generate(5, (i) {
          final filled = i < mastery;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.success : AppColors.border,
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.success.withOpacityCompat(0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// â”€â”€â”€ Rating Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.onRate});
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text('How well did you know this?', style: AppTextStyles.labelLG),
          const SizedBox(height: 14),
          Row(
            children: _ratings.map((r) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _RatingBtn(rating: r, onTap: () => onRate(r.quality)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RatingBtn extends StatefulWidget {
  const _RatingBtn({required this.rating, required this.onTap});
  final _Rating rating;
  final VoidCallback onTap;

  @override
  State<_RatingBtn> createState() => _RatingBtnState();
}

class _RatingBtnState extends State<_RatingBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: widget.rating.color.withOpacityCompat(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.rating.color.withOpacityCompat(0.30),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.rating.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 2),
              Text(
                widget.rating.label,
                style: AppTextStyles.labelLG.copyWith(
                  color: widget.rating.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Finish Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FinishSheet extends StatelessWidget {
  const _FinishSheet({
    required this.total,
    required this.deckTitle,
    required this.onRestart,
    required this.onQuiz,
    this.docId,
  });
  final int total;
  final String? deckTitle;
  final String? docId;
  final VoidCallback onRestart;
  final VoidCallback onQuiz;

  Future<void> _launchQuiz(BuildContext context) async {
    final id = docId;
    if (id == null) { onQuiz(); return; }
    final allQuizzes = await LocalQuizRepository.instance.getAllQuizzes(id);
    final hasQuizzes = allQuizzes.values.any((q) => q.isNotEmpty);
    if (!context.mounted) return;
    if (!hasQuizzes) { onQuiz(); return; }
    Navigator.pop(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuizDifficultySheet(
        allQuizzes: allQuizzes,
        deckTitle: deckTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        28,
        20,
        28,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          const SizedBox(height: 32),

          // Trophy glow
          GlowContainer(
            glowColor: AppColors.success,
            glowRadius: 60,
            glowOpacity: 0.35,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withOpacityCompat(0.12),
                border: Border.all(
                  color: AppColors.success.withOpacityCompat(0.3),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('ðŸ†', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Deck Complete!', style: AppTextStyles.displayMD),
          const SizedBox(height: 8),
          Text(
            'You reviewed all $total cards in ${deckTitle ?? 'this deck'}.',
            style: AppTextStyles.bodyMD,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Stats row
          Row(
            children: [
              _FinishStat(
                label: 'Reviewed',
                value: '$total',
                color: AppColors.amber,
              ),
              _FinishStat(
                label: 'Mastered',
                value: '${(total * 0.6).toInt()}',
                color: AppColors.success,
              ),
              _FinishStat(
                label: 'To retry',
                value: '${(total * 0.4).toInt()}',
                color: AppColors.error,
              ),
            ],
          ),

          const SizedBox(height: 32),

          PeckButton(
            label: 'Take a Quiz',
            onPressed: () => _launchQuiz(context),
            variant: PeckButtonVariant.primary,
            icon: const Icon(Icons.quiz_rounded),
          ),

          const SizedBox(height: 12),

          PeckButton(
            label: 'Restart Deck',
            onPressed: onRestart,
            variant: PeckButtonVariant.secondary,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _FinishStat extends StatelessWidget {
  const _FinishStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statMD.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelMD),
        ],
      ),
    );
  }
}

// ─── Quiz Difficulty Picker ───────────────────────────────────────────────────

class _QuizDifficultySheet extends StatelessWidget {
  const _QuizDifficultySheet({
    required this.allQuizzes,
    this.deckTitle,
  });
  final Map<ai_models.QuestionDifficulty, List<ai_models.QuizQuestion>> allQuizzes;
  final String? deckTitle;

  void _launch(BuildContext context, ai_models.QuestionDifficulty difficulty) {
    final raw = allQuizzes[difficulty] ?? [];
    if (raw.isEmpty) return;
    final questions = raw
        .map((q) => quiz_screen.QuizQuestion(
              question: q.question,
              options: q.options,
              correctIndex: q.correctIndex,
              explanation: q.explanation,
              subject: q.subject,
            ))
        .toList();
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => quiz_screen.QuizScreen(
          questions: questions,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      (difficulty: ai_models.QuestionDifficulty.easy, label: 'Easy', emoji: '😊', color: AppColors.success),
      (difficulty: ai_models.QuestionDifficulty.medium, label: 'Medium', emoji: '🤔', color: AppColors.warning),
      (difficulty: ai_models.QuestionDifficulty.difficult, label: 'Hard', emoji: '🔥', color: AppColors.error),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(28, 20, 28, MediaQuery.of(context).padding.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Choose Difficulty', style: AppTextStyles.headingMD),
          const SizedBox(height: 8),
          Text('Pick how hard you want the quiz to be', style: AppTextStyles.bodyMD),
          const SizedBox(height: 24),
          ...options.map((o) {
            final count = allQuizzes[o.difficulty]?.length ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _launch(context, o.difficulty),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: o.color.withOpacityCompat(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: o.color.withOpacityCompat(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(o.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.label, style: AppTextStyles.headingSM.copyWith(color: o.color)),
                            Text('$count questions', style: AppTextStyles.bodySM),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: o.color),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}













class _CardShimmer extends StatefulWidget {
  @override
  State<_CardShimmer> createState() => _CardShimmerState();
}

class _CardShimmerState extends State<_CardShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final c = Color.lerp(AppColors.bgCard, AppColors.bgSurface, _anim.value)!;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 80,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16)),
              ),
            )),
          ),
        );
      },
    );
  }
}

