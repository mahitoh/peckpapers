// lib/features/quiz/quiz_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_badge.dart';
import '../../core/widgets/peck_button.dart';
import '../../core/widgets/glow_container.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.subject,
  });
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? subject;
}

const _mockQuestions = [
  QuizQuestion(
    question: 'What does the Chain Rule state?',
    options: [
      'The derivative of a sum equals the sum of derivatives',
      'If y = f(g(x)), then dy/dx = f\'(g(x)) · g\'(x)',
      'The integral of a product of two functions',
      'The limit of a composite function as x approaches zero',
    ],
    correctIndex: 1,
    explanation:
        'The Chain Rule applies to composite functions. '
        'Differentiate the outer function, keep the inner, '
        'then multiply by the derivative of the inner function.',
    subject: 'Mathematics',
  ),
  QuizQuestion(
    question: 'Which law states that energy cannot be created or destroyed?',
    options: [
      'Newton\'s Second Law',
      'The Second Law of Thermodynamics',
      'The First Law of Thermodynamics',
      'The Law of Conservation of Momentum',
    ],
    correctIndex: 2,
    explanation:
        'The First Law of Thermodynamics is the law of '
        'conservation of energy. ΔU = Q − W.',
    subject: 'Physics',
  ),
  QuizQuestion(
    question: 'In an SN2 reaction, what causes Walden inversion?',
    options: [
      'Heat applied to the reaction mixture',
      'The leaving group departing first',
      'Back-side attack by the nucleophile',
      'Formation of a carbocation intermediate',
    ],
    correctIndex: 2,
    explanation:
        'In SN2, the nucleophile attacks the electrophilic '
        'carbon from the back (180° from the leaving group), '
        'inverting the stereochemistry — called Walden inversion.',
    subject: 'Chemistry',
  ),
  QuizQuestion(
    question: 'What does opportunity cost measure?',
    options: [
      'The total cost of producing one additional unit',
      'The monetary value of all resources used',
      'The value of the next best alternative forgone',
      'The difference between fixed and variable costs',
    ],
    correctIndex: 2,
    explanation:
        'Opportunity cost is the value of the next best '
        'alternative you give up when making a choice. '
        'It\'s implicit in every decision.',
    subject: 'Economics',
  ),
  QuizQuestion(
    question: 'Integration by parts follows which formula?',
    options: [
      '∫u dv = uv + ∫v du',
      '∫u dv = uv − ∫v du',
      '∫u dv = u/v − ∫v du',
      '∫u dv = (uv)² − ∫v du',
    ],
    correctIndex: 1,
    explanation:
        '∫u dv = uv − ∫v du. '
        'This is derived from the product rule. '
        'Use LIATE to choose u.',
    subject: 'Mathematics',
  ),
];

// ─── Quiz states ──────────────────────────────────────────────────────────────

enum _QuizState { active, results }

// ─── Screen ───────────────────────────────────────────────────────────────────

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.questions = _mockQuestions,
    this.timePerQuestion = 30,
    this.onBack,
    this.onFinish,
  });

  final List<QuizQuestion> questions;
  final int timePerQuestion; // seconds
  final VoidCallback? onBack;
  final VoidCallback? onFinish;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  _QuizState _quizState = _QuizState.active;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _timeLeft = 0;
  final _answers = <int?>[]; // null = timed out

  Timer? _timer;

  // Question entrance animation
  late AnimationController _questionCtrl;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;

  // Option reveal animation
  late AnimationController _optionsCtrl;
  late List<Animation<double>> _optionFades;

  // Timer ring animation
  late AnimationController _timerCtrl;

  // Feedback (correct/wrong) flash
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;

  QuizQuestion get _current => widget.questions[_currentIndex];
  bool get _isLastQ => _currentIndex >= widget.questions.length - 1;
  int get _correctCount => _answers
      .where(
        (a) =>
            a != null &&
            a == widget.questions[_answers.indexOf(a)].correctIndex,
      )
      .length;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timePerQuestion;
    _initAnimations();
    _startQuestion();
  }

  void _initAnimations() {
    // Question entrance
    _questionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _questionFade = CurvedAnimation(
      parent: _questionCtrl,
      curve: Curves.easeOut,
    );
    _questionSlide =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _questionCtrl, curve: Curves.easeOutCubic),
        );

    // Option stagger
    _optionsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _optionFades = List.generate(4, (i) {
      final start = i * 0.15;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _optionsCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    // Countdown ring
    _timerCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timePerQuestion),
    );

    // Feedback flash
    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackCtrl,
      curve: Curves.easeOut,
    );
  }

  void _startQuestion() {
    _timer?.cancel();
    _timeLeft = widget.timePerQuestion;
    _selectedOption = null;
    _answered = false;

    _questionCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _optionsCtrl.forward(from: 0);
    });
    _timerCtrl.forward(from: 0);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    HapticFeedback.heavyImpact();
    setState(() => _answered = true);
    _answers.add(null);
    _timerCtrl.stop();
    Future.delayed(const Duration(milliseconds: 1400), _advance);
  }

  void _selectOption(int index) {
    if (_answered) return;
    HapticFeedback.selectionClick();

    _timer?.cancel();
    _timerCtrl.stop();
    _feedbackCtrl.forward(from: 0);

    final correct = index == _current.correctIndex;
    if (correct) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }

    setState(() {
      _selectedOption = index;
      _answered = true;
    });
    _answers.add(index);

    // Auto advance after showing feedback
    Future.delayed(const Duration(milliseconds: 1800), _advance);
  }

  void _advance() {
    if (!mounted) return;
    if (_isLastQ) {
      setState(() => _quizState = _QuizState.results);
      return;
    }
    _questionCtrl.reset();
    _optionsCtrl.reset();
    _timerCtrl.reset();
    _feedbackCtrl.reset();
    setState(() => _currentIndex++);
    _startQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionCtrl.dispose();
    _optionsCtrl.dispose();
    _timerCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  // ── Compute per-answer correctness ────────────────────────────────────────────

  _OptionState _optionState(int index) {
    if (!_answered) return _OptionState.idle;
    if (index == _current.correctIndex) return _OptionState.correct;
    if (index == _selectedOption) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    if (_quizState == _QuizState.results) {
      return _ResultsScreen(
        questions: widget.questions,
        answers: _answers,
        onRetry: () {
          setState(() {
            _quizState = _QuizState.active;
            _currentIndex = 0;
            _answers.clear();
          });
          _startQuestion();
        },
        onDone: widget.onFinish ?? () => Navigator.pop(context),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────
            _QuizTopBar(
              current: _currentIndex + 1,
              total: widget.questions.length,
              onBack: widget.onBack ?? () => Navigator.pop(context),
              timeLeft: _timeLeft,
              totalTime: widget.timePerQuestion,
              timerCtrl: _timerCtrl,
            ),

            const SizedBox(height: 16),

            // ── Progress segments ─────────────────────────────
            _QuizProgressBar(
              answers: _answers,
              questions: widget.questions,
              current: _currentIndex,
              total: widget.questions.length,
            ),

            const SizedBox(height: 28),

            // ── Question ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _questionFade,
                child: SlideTransition(
                  position: _questionSlide,
                  child: _QuestionBlock(
                    question: _current,
                    index: _currentIndex,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Options ───────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _current.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => FadeTransition(
                  opacity: _optionFades[i],
                  child: _OptionTile(
                    label: _current.options[i],
                    index: i,
                    state: _optionState(i),
                    onTap: () => _selectOption(i),
                  ),
                ),
              ),
            ),

            // ── Explanation (after answer) ────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _answered && _current.explanation != null
                  ? _ExplanationBar(
                      key: const ValueKey('explanation'),
                      explanation: _current.explanation!,
                      isCorrect: _selectedOption == _current.correctIndex,
                    )
                  : const SizedBox.shrink(key: ValueKey('no-exp')),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Option state ─────────────────────────────────────────────────────────────

enum _OptionState { idle, correct, wrong, dimmed }

// ─── Quiz Top Bar ─────────────────────────────────────────────────────────────

class _QuizTopBar extends StatelessWidget {
  const _QuizTopBar({
    required this.current,
    required this.total,
    required this.onBack,
    required this.timeLeft,
    required this.totalTime,
    required this.timerCtrl,
  });
  final int current;
  final int total;
  final VoidCallback onBack;
  final int timeLeft;
  final int totalTime;
  final AnimationController timerCtrl;

  Color get _timerColor {
    final ratio = timeLeft / totalTime;
    if (ratio > 0.5) return AppColors.success;
    if (ratio > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back
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
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Question counter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question $current of $total',
                  style: AppTextStyles.headingMD,
                ),
                Text('Quiz Mode', style: AppTextStyles.bodyMD),
              ],
            ),
          ),

          // Circular countdown timer
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: timerCtrl,
                  builder: (_, _) => CircularProgressIndicator(
                    value: 1 - timerCtrl.value,
                    strokeWidth: 3.5,
                    color: _timerColor,
                    backgroundColor: AppColors.border,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTextStyles.headingSM.copyWith(color: _timerColor),
                  child: Text('$timeLeft'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quiz Progress Bar ────────────────────────────────────────────────────────

class _QuizProgressBar extends StatelessWidget {
  const _QuizProgressBar({
    required this.answers,
    required this.questions,
    required this.current,
    required this.total,
  });
  final List<int?> answers;
  final List<QuizQuestion> questions;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(total, (i) {
          Color color;
          if (i < answers.length) {
            final ans = answers[i];
            if (ans == null) {
              color = AppColors.warning;
            } else if (ans == questions[i].correctIndex) {
              color = AppColors.success;
            } else {
              color = AppColors.error;
            }
          } else if (i == current) {
            color = AppColors.amber;
          } else {
            color = AppColors.border;
          }

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: i == current
                    ? [
                        BoxShadow(
                          color: AppColors.amber.withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Question Block ───────────────────────────────────────────────────────────

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({required this.question, required this.index});
  final QuizQuestion question;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject badge
        if (question.subject != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PeckBadge(
              label: question.subject!,
              color: AppColors.violet,
              style: BadgeStyle.subtle,
            ),
          ),

        // Question number tag
        Text(
          'Q${index + 1}',
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 8),

        // Question text
        Text(
          question.question,
          style: AppTextStyles.headingXL.copyWith(height: 1.35),
        ),
      ],
    );
  }
}

// ─── Option Tile ──────────────────────────────────────────────────────────────

class _OptionTile extends StatefulWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.state,
    required this.onTap,
  });
  final String label;
  final int index;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // Resolve colors per state
  Color get _bgColor => switch (widget.state) {
    _OptionState.idle => AppColors.bgCard,
    _OptionState.correct => AppColors.success.withOpacity(0.10),
    _OptionState.wrong => AppColors.error.withOpacity(0.10),
    _OptionState.dimmed => AppColors.bgCard.withOpacity(0.4),
  };

  Color get _borderColor => switch (widget.state) {
    _OptionState.idle => AppColors.border,
    _OptionState.correct => AppColors.success.withOpacity(0.5),
    _OptionState.wrong => AppColors.error.withOpacity(0.5),
    _OptionState.dimmed => AppColors.border.withOpacity(0.3),
  };

  Color get _labelColor => switch (widget.state) {
    _OptionState.idle => AppColors.textPrimary,
    _OptionState.correct => AppColors.success,
    _OptionState.wrong => AppColors.error,
    _OptionState.dimmed => AppColors.textTertiary,
  };

  Color get _indexBg => switch (widget.state) {
    _OptionState.idle => AppColors.bgSurface,
    _OptionState.correct => AppColors.success,
    _OptionState.wrong => AppColors.error,
    _OptionState.dimmed => AppColors.bgSurface.withOpacity(0.4),
  };

  Color get _indexColor => switch (widget.state) {
    _OptionState.correct => Colors.white,
    _OptionState.wrong => Colors.white,
    _ => AppColors.textSecondary,
  };

  Widget get _trailingIcon => switch (widget.state) {
    _OptionState.correct => const Icon(
      Icons.check_circle_rounded,
      color: AppColors.success,
      size: 22,
    ),
    _OptionState.wrong => const Icon(
      Icons.cancel_rounded,
      color: AppColors.error,
      size: 22,
    ),
    _ => const SizedBox.shrink(),
  };

  List<BoxShadow> get _shadows => switch (widget.state) {
    _OptionState.correct => [
      BoxShadow(
        color: AppColors.success.withOpacity(0.2),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
    ],
    _OptionState.wrong => [
      BoxShadow(
        color: AppColors.error.withOpacity(0.2),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
    ],
    _ => [],
  };

  static const _labels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.state == _OptionState.idle
          ? (_) => _pressCtrl.forward()
          : null,
      onTapUp: widget.state == _OptionState.idle
          ? (_) {
              _pressCtrl.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.state == _OptionState.idle
          ? () => _pressCtrl.reverse()
          : null,
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: _shadows,
          ),
          child: Row(
            children: [
              // Index label box
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _indexBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: AppTextStyles.headingSM.copyWith(color: _indexColor),
                    child: Text(_labels[widget.index]),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Option text
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTextStyles.bodyMDMedium.copyWith(
                    color: _labelColor,
                  ),
                  child: Text(
                    widget.label,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Correct / wrong icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _trailingIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Explanation Bar ──────────────────────────────────────────────────────────

class _ExplanationBar extends StatelessWidget {
  const _ExplanationBar({
    super.key,
    required this.explanation,
    required this.isCorrect,
  });
  final String explanation;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct!' : 'Not quite',
                  style: AppTextStyles.headingSM.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: AppTextStyles.bodySM,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Results Screen ───────────────────────────────────────────────────────────

class _ResultsScreen extends StatefulWidget {
  const _ResultsScreen({
    required this.questions,
    required this.answers,
    required this.onRetry,
    required this.onDone,
  });
  final List<QuizQuestion> questions;
  final List<int?> answers;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  State<_ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<_ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreCtrl;
  late Animation<double> _scoreArc;
  late Animation<double> _scoreFade;

  int get _correct => widget.answers
      .asMap()
      .entries
      .where((e) => e.value == widget.questions[e.key].correctIndex)
      .length;
  int get _timedOut => widget.answers.where((a) => a == null).length;
  int get _wrong => widget.answers.length - _correct - _timedOut;

  double get _scoreRatio => _correct / widget.questions.length;

  String get _grade {
    if (_scoreRatio >= 0.9) return 'A+';
    if (_scoreRatio >= 0.8) return 'A';
    if (_scoreRatio >= 0.7) return 'B';
    if (_scoreRatio >= 0.6) return 'C';
    if (_scoreRatio >= 0.5) return 'D';
    return 'F';
  }

  Color get _gradeColor {
    if (_scoreRatio >= 0.8) return AppColors.success;
    if (_scoreRatio >= 0.6) return AppColors.amber;
    return AppColors.error;
  }

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreArc = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic);
    _scoreFade = CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut);
    _scoreCtrl.forward();
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: FadeTransition(
          opacity: _scoreFade,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Score hero ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: _ScoreHero(
                    correct: _correct,
                    total: widget.questions.length,
                    grade: _grade,
                    gradeColor: _gradeColor,
                    scoreRatio: _scoreRatio,
                    scoreArc: _scoreArc,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Stat chips ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ResultChip(
                          value: '$_correct',
                          label: 'Correct',
                          color: AppColors.success,
                          icon: Icons.check_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultChip(
                          value: '$_wrong',
                          label: 'Wrong',
                          color: AppColors.error,
                          icon: Icons.close_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultChip(
                          value: '$_timedOut',
                          label: 'Timed out',
                          color: AppColors.warning,
                          icon: Icons.timer_off_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Review header ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Review Answers', style: AppTextStyles.headingMD),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── Answer review list ───────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  final q = widget.questions[i];
                  final ans = widget.answers[i];
                  final isCorrect = ans == q.correctIndex;
                  final timedOut = ans == null;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: _ReviewCard(
                      index: i,
                      question: q,
                      answer: ans,
                      isCorrect: isCorrect,
                      timedOut: timedOut,
                    ),
                  );
                }, childCount: widget.questions.length),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Action buttons ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      PeckButton(
                        label: 'Try Again',
                        onPressed: widget.onRetry,
                        variant: PeckButtonVariant.secondary,
                        icon: const Icon(Icons.replay_rounded),
                      ),
                      const SizedBox(height: 12),
                      PeckButton(
                        label: 'Done',
                        onPressed: widget.onDone,
                        variant: PeckButtonVariant.primary,
                        icon: const Icon(Icons.check_rounded),
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
}

// ─── Score Hero ───────────────────────────────────────────────────────────────

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({
    required this.correct,
    required this.total,
    required this.grade,
    required this.gradeColor,
    required this.scoreRatio,
    required this.scoreArc,
  });
  final int correct;
  final int total;
  final String grade;
  final Color gradeColor;
  final double scoreRatio;
  final Animation<double> scoreArc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Quiz Complete', style: AppTextStyles.displayMD),
        const SizedBox(height: 6),
        Text('Here\'s how you did', style: AppTextStyles.bodyMD),

        const SizedBox(height: 32),

        // Score ring
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: scoreArc,
                builder: (_, _) => CircularProgressIndicator(
                  value: scoreRatio * scoreArc.value,
                  strokeWidth: 10,
                  color: gradeColor,
                  backgroundColor: AppColors.border,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    grade,
                    style: AppTextStyles.statXL.copyWith(color: gradeColor),
                  ),
                  Text('$correct/$total correct', style: AppTextStyles.labelLG),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Score percentage
        GlowContainer(
          glowColor: gradeColor,
          glowRadius: 30,
          glowOpacity: 0.25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: gradeColor.withOpacity(0.25), width: 1),
            ),
            child: Text(
              '${(scoreRatio * 100).toInt()}% Score',
              style: AppTextStyles.headingMD.copyWith(color: gradeColor),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Result Chip ──────────────────────────────────────────────────────────────

class _ResultChip extends StatelessWidget {
  const _ResultChip({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.statMD.copyWith(color: color)),
          Text(label, style: AppTextStyles.labelMD),
        ],
      ),
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────────────────────

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.isCorrect,
    required this.timedOut,
  });
  final int index;
  final QuizQuestion question;
  final int? answer;
  final bool isCorrect;
  final bool timedOut;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  Color get _accentColor {
    if (widget.timedOut) return AppColors.warning;
    if (widget.isCorrect) return AppColors.success;
    return AppColors.error;
  }

  IconData get _icon {
    if (widget.timedOut) return Icons.timer_off_rounded;
    if (widget.isCorrect) return Icons.check_circle_rounded;
    return Icons.cancel_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _accentColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(_icon, color: _accentColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.question.question,
                    style: AppTextStyles.bodyMDMedium,
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),

            // Expanded detail
            if (_expanded) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              // Correct answer
              _ReviewRow(
                label: 'Correct',
                text: widget.question.options[widget.question.correctIndex],
                color: AppColors.success,
                icon: Icons.check_rounded,
              ),

              // User's answer (if wrong)
              if (!widget.isCorrect && widget.answer != null) ...[
                const SizedBox(height: 8),
                _ReviewRow(
                  label: 'Your answer',
                  text: widget.question.options[widget.answer!],
                  color: AppColors.error,
                  icon: Icons.close_rounded,
                ),
              ],

              if (widget.timedOut) ...[
                const SizedBox(height: 8),
                _ReviewRow(
                  label: 'Your answer',
                  text: 'Timed out',
                  color: AppColors.warning,
                  icon: Icons.timer_off_rounded,
                ),
              ],

              // Explanation
              if (widget.question.explanation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.textTertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.question.explanation!,
                          style: AppTextStyles.bodySM,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.text,
    required this.color,
    required this.icon,
  });
  final String label;
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelCaps.copyWith(
                  color: color,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(text, style: AppTextStyles.bodyMDMedium),
            ],
          ),
        ),
      ],
    );
  }
}
