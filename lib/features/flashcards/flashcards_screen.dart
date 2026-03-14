// lib/features/flashcards/flashcards_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_button.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/glow_container.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class FlashcardData {
  const FlashcardData({
    required this.question,
    required this.answer,
    required this.subject,
    this.hint,
    this.mastery = 0,
  });

  final String question;
  final String answer;
  final String subject;
  final String? hint;
  final int mastery; // 0–5
}

// ─── Mock deck ────────────────────────────────────────────────────────────────

const _mockDeck = [
  FlashcardData(
    question: 'What is integration by parts?',
    answer:
        '∫u dv = uv − ∫v du\n\nUsed when integrating a product of two functions. Choose u using LIATE: Logarithm, Inverse trig, Algebraic, Trig, Exponential.',
    subject: 'Calculus',
    hint: 'Think of it as the product rule in reverse.',
    mastery: 3,
  ),
  FlashcardData(
    question: 'Define the Fundamental Theorem of Calculus.',
    answer:
        'If F is an antiderivative of f on [a,b], then:\n∫ₐᵇ f(x)dx = F(b) − F(a)\n\nLinks differentiation and integration.',
    subject: 'Calculus',
    mastery: 1,
  ),
  FlashcardData(
    question: 'What is L\'Hôpital\'s Rule?',
    answer:
        'If lim f(x)/g(x) gives 0/0 or ∞/∞, then:\nlim f(x)/g(x) = lim f\'(x)/g\'(x)\n\nApply repeatedly until limit resolves.',
    subject: 'Calculus',
    hint: 'Only applies to indeterminate forms.',
    mastery: 5,
  ),
  FlashcardData(
    question: 'What does the chain rule state?',
    answer:
        'd/dx[f(g(x))] = f\'(g(x)) · g\'(x)\n\nThe derivative of a composite function — outside times derivative of inside.',
    subject: 'Calculus',
    mastery: 2,
  ),
  FlashcardData(
    question: 'Define a limit formally (ε-δ definition).',
    answer:
        'lim x→a f(x) = L means:\nFor every ε > 0 there exists δ > 0 such that\n0 < |x−a| < δ ⟹ |f(x)−L| < ε',
    subject: 'Calculus',
    mastery: 0,
  ),
];

// ─── Rating config ────────────────────────────────────────────────────────────

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

const _ratings = [
  _Rating(label: 'Hard', emoji: '😓', color: AppColors.error, quality: 1),
  _Rating(label: 'Good', emoji: '🙂', color: AppColors.warning, quality: 3),
  _Rating(label: 'Easy', emoji: '🚀', color: AppColors.success, quality: 5),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({
    super.key,
    this.deck = _mockDeck,
    this.deckTitle = 'Calculus',
    this.onFinished,
    this.onBack,
    this.onQuizTap,
  });

  final List<FlashcardData> deck;
  final String deckTitle;
  final VoidCallback? onFinished;
  final VoidCallback? onBack;
  final VoidCallback? onQuizTap;

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen>
    with TickerProviderStateMixin {
  int _index = 0;
  bool _flipped = false;

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

  FlashcardData get _current => widget.deck[_index];
  bool get _isLast => _index == widget.deck.length - 1;

  @override
  void initState() {
    super.initState();

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
  void dispose() {
    _flipCtrl.dispose();
    _enterCtrl.dispose();
    _ratingCtrl.dispose();
    super.dispose();
  }

  // ── Flip card ──────────────────────────────────────────────────

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

  // ── Rate & advance ─────────────────────────────────────────────

  void _rate(int quality) {
    HapticFeedback.mediumImpact();

    if (_isLast) {
      widget.onFinished?.call();
      _showFinishSheet();
      return;
    }

    setState(() {
      _flipped = false;
      _index++;
    });

    _flipCtrl.reset();
    _ratingCtrl.reset();
    _enterCtrl.reset();
    _enterCtrl.forward();
  }

  // ── Swipe gesture ──────────────────────────────────────────────

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragDx = d.primaryDelta ?? 0);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    setState(() => _dragDx = 0);

    if (velocity > 600 && _index > 0) {
      // Swipe right — go back
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

  // ── Finish sheet ───────────────────────────────────────────────

  void _showFinishSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FinishSheet(
        total: widget.deck.length,
        deckTitle: widget.deckTitle,
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────
            _TopBar(
              title: widget.deckTitle,
              onBack: widget.onBack ?? () => Navigator.pop(context),
              onMore: () {},
            ),

            const SizedBox(height: 8),

            // ── Progress row ──────────────────────────────────────
            _ProgressRow(current: _index + 1, total: widget.deck.length),

            const SizedBox(height: 32),

            // ── Card area ─────────────────────────────────────────
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

            // ── Tap hint ──────────────────────────────────────────
            AnimatedOpacity(
              opacity: _flipped ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
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

            // ── Rating buttons ────────────────────────────────────
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

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onMore,
  });
  final String title;
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
                Text(title, style: AppTextStyles.headingLG),
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

// ─── Progress Row ─────────────────────────────────────────────────────────────

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
                                color: AppColors.amber.withOpacity(0.5),
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

// ─── Flip Card ────────────────────────────────────────────────────────────────

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

// ─── Card Face ────────────────────────────────────────────────────────────────

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
                    AppColors.violet.withOpacity(0.18),
                    AppColors.bgCard,
                    AppColors.bgCard,
                  ],
                ),
          border: Border.all(
            color: isFront
                ? AppColors.border
                : AppColors.violet.withOpacity(0.35),
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
                      .withOpacity(0.04),
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
                      .withOpacity(0.04),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row — label + subject chip
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

                  // Bottom row — mastery dots
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

// ─── Question Side ────────────────────────────────────────────────────────────

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
              border: Border.all(color: AppColors.amber.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.amber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.hint!,
                    style: AppTextStyles.bodySM.copyWith(
                      color: AppColors.amber.withOpacity(0.85),
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

// ─── Answer Side ──────────────────────────────────────────────────────────────

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
                color: AppColors.violet.withOpacity(0.5),
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

// ─── Mastery Row ──────────────────────────────────────────────────────────────

class _MasteryRow extends StatelessWidget {
  const _MasteryRow({required this.mastery});
  final int mastery; // 0–5

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
                          color: AppColors.success.withOpacity(0.5),
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

// ─── Rating Row ───────────────────────────────────────────────────────────────

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
            color: widget.rating.color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.rating.color.withOpacity(0.30),
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

// ─── Finish Sheet ─────────────────────────────────────────────────────────────

class _FinishSheet extends StatelessWidget {
  const _FinishSheet({
    required this.total,
    required this.deckTitle,
    required this.onRestart,
    required this.onQuiz,
  });
  final int total;
  final String deckTitle;
  final VoidCallback onRestart;
  final VoidCallback onQuiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
                color: AppColors.success.withOpacity(0.12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Deck Complete!', style: AppTextStyles.displayMD),
          const SizedBox(height: 8),
          Text(
            'You reviewed all $total cards in $deckTitle.',
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
            onPressed: onQuiz,
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
