import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DayActivity {
  DayActivity({required this.day, required this.minutes});
  final String day;
  int minutes;

  Map<String, dynamic> toJson() => {'day': day, 'minutes': minutes};
  factory DayActivity.fromJson(Map<String, dynamic> json) =>
      DayActivity(day: json['day'] as String, minutes: json['minutes'] as int);
}

class SubjectMastery {
  SubjectMastery({
    required this.subject,
    required this.mastery,
    required this.cards,
    required this.colorValue,
  });
  final String subject;
  double mastery;
  int cards;
  int colorValue;

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'mastery': mastery,
        'cards': cards,
        'colorValue': colorValue,
      };
  factory SubjectMastery.fromJson(Map<String, dynamic> json) => SubjectMastery(
        subject: json['subject'] as String,
        mastery: (json['mastery'] as num).toDouble(),
        cards: json['cards'] as int,
        colorValue: json['colorValue'] as int,
      );
}

class AnalyticsData {
  AnalyticsData({
    required this.studyTimeMinutes,
    required this.worldRank,
    required this.weekActivity,
    required this.subjects,
    required this.heatmap,
    required this.weakTopics,
    required this.totalDocuments,
    required this.totalQuizzesTaken,
    required this.totalCorrectAnswers,
  });

  int studyTimeMinutes;
  int worldRank;
  List<DayActivity> weekActivity;
  List<SubjectMastery> subjects;
  List<int> heatmap; // 35 days, index 0 = 35 days ago, index 34 = today
  List<String> weakTopics;
  int totalDocuments;
  int totalQuizzesTaken;
  int totalCorrectAnswers;

  double get accuracy => totalQuizzesTaken == 0
      ? 0
      : (totalCorrectAnswers / totalQuizzesTaken).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'studyTimeMinutes': studyTimeMinutes,
        'worldRank': worldRank,
        'weekActivity': weekActivity.map((e) => e.toJson()).toList(),
        'subjects': subjects.map((e) => e.toJson()).toList(),
        'heatmap': heatmap,
        'weakTopics': weakTopics,
        'totalDocuments': totalDocuments,
        'totalQuizzesTaken': totalQuizzesTaken,
        'totalCorrectAnswers': totalCorrectAnswers,
      };

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
        studyTimeMinutes: json['studyTimeMinutes'] as int? ?? 0,
        worldRank: json['worldRank'] as int? ?? 1000,
        weekActivity: (json['weekActivity'] as List<dynamic>?)
                ?.map((e) => DayActivity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            _defaultWeekActivity(),
        subjects: (json['subjects'] as List<dynamic>?)
                ?.map((e) => SubjectMastery.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        heatmap: (json['heatmap'] as List<dynamic>?)?.map((e) => e as int).toList() ??
            List.filled(35, 0),
        weakTopics: (json['weakTopics'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        totalDocuments: json['totalDocuments'] as int? ?? 0,
        totalQuizzesTaken: json['totalQuizzesTaken'] as int? ?? 0,
        totalCorrectAnswers: json['totalCorrectAnswers'] as int? ?? 0,
      );

  static List<DayActivity> _defaultWeekActivity() => [
        DayActivity(day: 'Mon', minutes: 0),
        DayActivity(day: 'Tue', minutes: 0),
        DayActivity(day: 'Wed', minutes: 0),
        DayActivity(day: 'Thu', minutes: 0),
        DayActivity(day: 'Fri', minutes: 0),
        DayActivity(day: 'Sat', minutes: 0),
        DayActivity(day: 'Sun', minutes: 0),
      ];
}

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const _key = 'analytics_data_v2';
  static const _heatmapDatesKey = 'analytics_heatmap_dates';

  // Stream controller for real-time updates
  final _controller = StreamController<AnalyticsData>.broadcast();
  Stream<AnalyticsData> get stream => _controller.stream;

  Future<AnalyticsData> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return _createDefault();
    try {
      return AnalyticsData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return _createDefault();
    }
  }

  Future<void> _save(AnalyticsData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
    _controller.add(data); // push real-time update
  }

  /// Call when user studies flashcards
  Future<void> logStudyTime(int minutes) async {
    final data = await getData();
    data.studyTimeMinutes += minutes;

    // Update today's slot in weekActivity (0=Mon … 6=Sun)
    final todayIdx = DateTime.now().weekday - 1;
    if (todayIdx >= 0 && todayIdx < data.weekActivity.length) {
      data.weekActivity[todayIdx].minutes += minutes;
    }

    // Update heatmap for today (index 34)
    _bumpHeatmap(data);

    // Improve world rank slightly
    data.worldRank = (data.worldRank - (minutes ~/ 5)).clamp(1, 999999);

    await _save(data);
  }

  /// Call when a document is scanned/saved
  Future<void> logDocumentScanned(String subject, int cardCount, int colorValue) async {
    final data = await getData();
    data.totalDocuments++;

    final idx = data.subjects.indexWhere((s) => s.subject == subject);
    if (idx >= 0) {
      data.subjects[idx].cards += cardCount;
      data.subjects[idx].mastery = (data.subjects[idx].mastery + 0.05).clamp(0.0, 1.0);
    } else {
      data.subjects.add(SubjectMastery(
        subject: subject,
        mastery: 0.1,
        cards: cardCount,
        colorValue: colorValue,
      ));
    }

    _bumpHeatmap(data);
    await _save(data);
  }

  /// Keep for backward compat
  Future<void> logSubjectCardGeneration(String subject, int count, int colorValue) =>
      logDocumentScanned(subject, count, colorValue);

  /// Call after each quiz question answered
  Future<void> logQuizResult(String subject, bool isCorrect) async {
    final data = await getData();
    data.totalQuizzesTaken++;
    if (isCorrect) data.totalCorrectAnswers++;

    final idx = data.subjects.indexWhere((s) => s.subject == subject);
    if (idx >= 0) {
      data.subjects[idx].mastery = isCorrect
          ? (data.subjects[idx].mastery + 0.02).clamp(0.0, 1.0)
          : (data.subjects[idx].mastery - 0.04).clamp(0.0, 1.0);
    }

    // Refresh weak topics
    final sorted = List<SubjectMastery>.from(data.subjects)
      ..sort((a, b) => a.mastery.compareTo(b.mastery));
    data.weakTopics = sorted.where((s) => s.mastery < 0.6).take(3).map((s) => s.subject).toList();

    // Rank improves with correct answers
    if (isCorrect) data.worldRank = (data.worldRank - 1).clamp(1, 999999);

    await _save(data);
  }

  /// Bump today's heatmap cell (0–4 scale)
  void _bumpHeatmap(AnalyticsData data) {
    if (data.heatmap.length < 35) {
      data.heatmap = List.filled(35, 0);
    }
    data.heatmap[34] = (data.heatmap[34] + 1).clamp(0, 4);
  }

  AnalyticsData _createDefault() => AnalyticsData(
        studyTimeMinutes: 0,
        worldRank: 1000,
        weekActivity: AnalyticsData._defaultWeekActivity(),
        subjects: [],
        heatmap: List.filled(35, 0),
        weakTopics: [],
        totalDocuments: 0,
        totalQuizzesTaken: 0,
        totalCorrectAnswers: 0,
      );
}
