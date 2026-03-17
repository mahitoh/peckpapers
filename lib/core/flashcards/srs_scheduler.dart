import 'flashcard_models.dart';

class SrsScheduler {
  const SrsScheduler();

  ReviewLog schedule({
    required String cardId,
    required int quality,
    required DateTime now,
    ReviewLog? previous,
  }) {
    final clampedQuality = quality.clamp(0, 5);
    final prevEase = previous?.easeFactor ?? 2.5;
    var ease = prevEase +
        (0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02));
    if (ease < 1.3) ease = 1.3;

    int intervalDays;
    if (clampedQuality < 3) {
      intervalDays = 1;
    } else if (previous == null) {
      intervalDays = 1;
    } else if (previous.intervalDays == 1) {
      intervalDays = 6;
    } else {
      intervalDays = (previous.intervalDays * ease).round();
    }

    final nextDue = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: intervalDays));

    return ReviewLog(
      cardId: cardId,
      quality: clampedQuality,
      reviewedAt: now,
      nextDue: nextDue,
      intervalDays: intervalDays,
      easeFactor: ease,
    );
  }
}
