import 'package:drift/drift.dart';

// Goal preset templates table
class GoalPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goalType => text()(); // prayer, quranReading, etc.
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  IntColumn get defaultTargetCount => integer().withDefault(const Constant(1))();
  TextColumn get icon => text().withLength(min: 1, max: 10)();
  TextColumn get color => text().withLength(min: 6, max: 7)(); // Hex color code
  BoolColumn get isRecommended => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))(); // User-created presets
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
}

// Daily goals table - stores specific daily goal instances
class DailyGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goalId => text()(); // Unique identifier for the goal instance
  IntColumn get presetId => integer().references(GoalPresets, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  IntColumn get targetCount => integer().withDefault(const Constant(1))();
  IntColumn get currentCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, completed, skipped
  DateTimeColumn get date => dateTime()(); // Date this goal is for
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get customNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

// Goal progress tracking - detailed progress tracking
class GoalProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyGoalId => integer().references(DailyGoals, #id)();
  IntColumn get incrementValue => integer().withDefault(const Constant(1))(); // How much progress was made
  TextColumn get note => text().nullable()(); // Optional note for this progress entry
  DateTimeColumn get timestamp => dateTime().withDefault(Constant(DateTime.now()))();
}

// Goal history for analytics and past performance
class GoalHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goalType => text()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get targetCount => integer()();
  IntColumn get achievedCount => integer()();
  BoolColumn get wasCompleted => boolean()();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
}

// Goal notification settings
class GoalNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get presetId => integer().references(GoalPresets, #id)();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get reminderTime => text()(); // Time in HH:mm format
  TextColumn get reminderDays => text()(); // JSON array of days [1,2,3,4,5,6,7] for week days
  TextColumn get customMessage => text().nullable()();
  BoolColumn get isDaily => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
}

// Goal statistics and achievements
class GoalStatistics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goalType => text()();
  IntColumn get totalGoals => integer().withDefault(const Constant(0))();
  IntColumn get completedGoals => integer().withDefault(const Constant(0))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedDate => dateTime().nullable()();
  DateTimeColumn get firstGoalDate => dateTime().nullable()();
  RealColumn get completionRate => real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
} 