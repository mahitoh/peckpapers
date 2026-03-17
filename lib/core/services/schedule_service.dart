import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduledActivity {
  ScheduledActivity({
    required this.id,
    required this.docId,
    required this.title,
    required this.subject,
    required this.scheduledTime,
    this.completed = false,
  });

  final String id;
  final String docId;
  final String title;
  final String subject;
  final DateTime scheduledTime;
  bool completed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'docId': docId,
        'title': title,
        'subject': subject,
        'scheduledTime': scheduledTime.toIso8601String(),
        'completed': completed,
      };

  factory ScheduledActivity.fromJson(Map<String, dynamic> json) => ScheduledActivity(
        id: json['id'] as String,
        docId: json['docId'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String,
        scheduledTime: DateTime.parse(json['scheduledTime'] as String),
        completed: json['completed'] as bool? ?? false,
      );
}

class ScheduleService {
  ScheduleService._();
  static final ScheduleService instance = ScheduleService._();

  static const _key = 'study_schedule';

  Future<List<ScheduledActivity>> getSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => ScheduledActivity.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> scheduleActivity(ScheduledActivity activity) async {
    final schedule = await getSchedule();
    schedule.add(activity);
    await _saveAll(schedule);
  }

  Future<void> toggleComplete(String id) async {
    final schedule = await getSchedule();
    final index = schedule.indexWhere((a) => a.id == id);
    if (index >= 0) {
      schedule[index].completed = !schedule[index].completed;
      await _saveAll(schedule);
    }
  }

  Future<void> deleteActivity(String id) async {
    final schedule = await getSchedule();
    schedule.removeWhere((a) => a.id == id);
    await _saveAll(schedule);
  }

  Future<void> _saveAll(List<ScheduledActivity> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = schedule.map((a) => a.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
