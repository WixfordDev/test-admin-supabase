import 'package:equatable/equatable.dart';

enum GoalType {
  prayer, // Offer each Prayer
  quranReading, // Listen to Al-Quran
  quranMemorization, // Memorize Al-Quran
  dhikr, // Dhikr/Remembrance
  sadaqah, // Give Sadaqah
  fastingMonday, // Fast on Monday
  fastingThursday, // Fast on Thursday
  surahKahf, // Recite Surah Kahf on Friday
  duaRecitation, // Daily Dua recitation
  hadithReading, // Read Hadith
  istighfar, // Seek forgiveness
  salawat, // Send blessings on Prophet
}

enum GoalStatus {
  pending,
  completed,
  skipped,
}

class DailyGoal extends Equatable {
  final String id;
  final GoalType type;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final GoalStatus status;
  final DateTime date;
  final bool isActive;
  final String? customNote;

  const DailyGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetCount,
    this.currentCount = 0,
    this.status = GoalStatus.pending,
    required this.date,
    this.isActive = true,
    this.customNote,
  });

  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => status == GoalStatus.completed || currentCount >= targetCount;

  DailyGoal copyWith({
    String? id,
    GoalType? type,
    String? title,
    String? description,
    int? targetCount,
    int? currentCount,
    GoalStatus? status,
    DateTime? date,
    bool? isActive,
    String? customNote,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      status: status ?? this.status,
      date: date ?? this.date,
      isActive: isActive ?? this.isActive,
      customNote: customNote ?? this.customNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'status': status.name,
      'date': date.toIso8601String(),
      'isActive': isActive,
      'customNote': customNote,
    };
  }

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      id: json['id'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      targetCount: json['targetCount'],
      currentCount: json['currentCount'] ?? 0,
      status: GoalStatus.values.firstWhere((e) => e.name == json['status']),
      date: DateTime.parse(json['date']),
      isActive: json['isActive'] ?? true,
      customNote: json['customNote'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        targetCount,
        currentCount,
        status,
        date,
        isActive,
        customNote,
      ];
}

class GoalTemplate extends Equatable {
  final GoalType type;
  final String title;
  final String description;
  final int defaultTargetCount;
  final String icon;
  final String color;
  final bool isRecommended;

  const GoalTemplate({
    required this.type,
    required this.title,
    required this.description,
    required this.defaultTargetCount,
    required this.icon,
    required this.color,
    this.isRecommended = false,
  });

  DailyGoal toDailyGoal({required DateTime date, String? customNote}) {
    return DailyGoal(
      id: '${type.name}_${date.toIso8601String().split('T')[0]}',
      type: type,
      title: title,
      description: description,
      targetCount: defaultTargetCount,
      date: date,
      customNote: customNote,
    );
  }

  @override
  List<Object?> get props => [type, title, description, defaultTargetCount, icon, color, isRecommended];
} 