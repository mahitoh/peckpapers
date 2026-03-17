import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/ai/ai_models.dart';
import '../../core/quiz/local_quiz_repository.dart';
import '../../core/services/library_service.dart';
import '../../core/services/schedule_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_badge.dart';
import '../quiz/quiz_screen.dart' as quiz_screen;

class NotesDetailScreen extends StatefulWidget {
  const NotesDetailScreen({super.key, required this.document});

  final Document document;

  @override
  State<NotesDetailScreen> createState() => _NotesDetailScreenState();
}

class _NotesDetailScreenState extends State<NotesDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  Map<QuestionDifficulty, List<QuizQuestion>> _quizzes = {};
  bool _loadingQuizzes = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadQuizzes();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _loadingQuizzes = true);
    try {
      final quizzes = await LocalQuizRepository.instance.getAllQuizzes(widget.document.id);
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _loadingQuizzes = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingQuizzes = false);
      }
    }
  }

  void _openQuiz(QuestionDifficulty difficulty) {
    final questions = _quizzes[difficulty] ?? [];
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No quizzes available for this difficulty.')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    
    // Convert to quiz_screen's QuizQuestion format
    final convertedQuestions = questions
        .map(
          (q) => quiz_screen.QuizQuestion(
            question: q.question,
            options: q.options,
            correctIndex: q.correctIndex,
            explanation: q.explanation,
            subject: q.subject,
          ),
        )
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => quiz_screen.QuizScreen(
          questions: convertedQuestions,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSummary = widget.document.summary != null && 
        widget.document.summary!.text.isNotEmpty;
    final hasQuizzes = widget.document.totalQuizCount > 0;

    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        appBar: AppBar(
          backgroundColor: AppColors.bgBase,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: Text(
            widget.document.title,
            style: AppTextStyles.headingLG,
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: _showScheduleSheet,
              icon: const Icon(Icons.calendar_today_rounded),
              tooltip: 'Schedule Study',
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject badge
                PeckBadge(
                  label: widget.document.subject,
                  icon: const Icon(Icons.book_rounded),
                ),
                const SizedBox(height: 20),

                // Summary Section
                if (hasSummary) ...[
                  Text(
                    'Summary',
                    style: AppTextStyles.headingMD.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.document.summary!.text,
                          style: AppTextStyles.bodyMD.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        if (widget.document.summary!.sections.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...widget.document.summary!.sections.map((section) {
                            return _buildSection(section);
                          }),
                        ] else if (widget.document.summary!.bullets.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Key Points',
                            style: AppTextStyles.bodyMD.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...widget.document.summary!.bullets.map((bullet) {
                            return _buildBulletRow(bullet);
                          }),
                        ],
                      ],
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No summary generated yet.',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Quizzes Section
                Text(
                  'Quizzes',
                  style: AppTextStyles.headingMD.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (_loadingQuizzes)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (hasQuizzes)
                  Column(
                    children: [
                      _buildQuizCard(
                        difficulty: QuestionDifficulty.easy,
                        count: widget.document.easyQuizCount,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildQuizCard(
                        difficulty: QuestionDifficulty.medium,
                        count: widget.document.mediumQuizCount,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildQuizCard(
                        difficulty: QuestionDifficulty.difficult,
                        count: widget.document.difficultQuizCount,
                        color: Colors.red,
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No quizzes generated yet.',
                        style: AppTextStyles.bodyMD.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Metadata
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Pages', '${widget.document.pageCount}'),
                      const SizedBox(height: 8),
                      _infoRow('Flashcards', '${widget.document.cardCount}'),
                      const SizedBox(height: 8),
                      _infoRow('Total Quizzes', '${widget.document.totalQuizCount}'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard({
    required QuestionDifficulty difficulty,
    required int count,
    required Color color,
  }) {
    final difficultyLabel = difficulty.name[0].toUpperCase() +
        difficulty.name.substring(1);
    
    return GestureDetector(
      onTap: () => _openQuiz(difficulty),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficultyLabel,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count question${count != 1 ? 's' : ''}',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(SummarySection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.topic,
            style: AppTextStyles.headingSM.copyWith(
              color: AppColors.amber,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.content,
            style: AppTextStyles.bodyMD.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.bullets.map((b) => _buildBulletRow(b)),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletRow(String bullet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodySM.copyWith(
              color: AppColors.amber,
            ),
          ),
          Expanded(
            child: Text(
              bullet,
              style: AppTextStyles.bodySM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleSheet(
        document: widget.document,
        onScheduled: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Study session scheduled!')),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySM.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyMD.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.amber),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({required this.document, required this.onScheduled});
  final Document document;
  final VoidCallback onScheduled;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  String _type = 'Reading'; // Reading, Quiz, Flashcards

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule Study', style: AppTextStyles.headingMD),
          const SizedBox(height: 20),
          Text('Activity Type', style: AppTextStyles.labelLG),
          const SizedBox(height: 8),
          Row(
            children: [
              _typeChip('Reading'),
              const SizedBox(width: 8),
              _typeChip('Quiz'),
              const SizedBox(width: 8),
              _typeChip('Flashcards'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Time', style: AppTextStyles.labelLG),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.access_time_rounded, color: AppColors.primary),
            title: Text(
              '${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.bodyMDMedium,
            ),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: AppTextStyles.bodySM,
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_selectedDate),
                );
                if (time != null) {
                  setState(() {
                    _selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {              if (!mounted) return;               final navigator = Navigator.of(context);
                final activity = ScheduledActivity(
                  id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
                  docId: widget.document.id,
                  title: '${widget.document.title} - $_type',
                  subject: widget.document.subject,
                  scheduledTime: _selectedDate,
                );
                await ScheduleService.instance.scheduleActivity(activity);
                widget.onScheduled();
                navigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirm Schedule'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _typeChip(String label) {
    final active = _type == label;
    return GestureDetector(
      onTap: () => setState(() => _type = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySM.copyWith(
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
