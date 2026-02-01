import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

// Import all table definitions
import 'package:deenhub/core/services/database/tables/chat_tables.dart';
import 'package:deenhub/core/services/database/tables/goal_tables.dart';
import 'package:deenhub/core/services/database/tables/quran_tables.dart';
import 'package:deenhub/core/services/database/tables/recently_read_tables.dart';

// Import all DAOs
import 'package:deenhub/core/services/database/daos/chat_dao.dart';
import 'package:deenhub/core/services/database/daos/goals_dao.dart';
import 'package:deenhub/core/services/database/daos/quran_dao.dart';
import 'package:deenhub/core/services/database/daos/recently_read_dao.dart';

part 'app_database.g.dart';

// Database Class
@DriftDatabase(
  tables: [
    // Chat tables
    ChatSessions,
    ChatMessages,
    
    // Goal tables
    GoalPresets,
    DailyGoals,
    GoalProgress,
    GoalHistory,
    GoalNotifications,
    GoalStatistics,
    
    // Quran tables
    QuranDataTable,
    SurahTable,
    AyahTable,
    
    // Recently read tables
    RecentlyReadEntries,
  ],
  daos: [
    ChatDao,
    GoalsDao,
    QuranDao,
    RecentlyReadDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4; // Updated schema version for new Quran tables

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        // Initialize default goal presets
        await goalsDao.initializeDefaultPresets();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Create new goal-related tables
          await migrator.createTable(goalPresets);
          await migrator.createTable(dailyGoals);
          await migrator.createTable(goalProgress);
          await migrator.createTable(goalHistory);
          await migrator.createTable(goalNotifications);
          await migrator.createTable(goalStatistics);
          
          // Initialize default goal presets
          await goalsDao.initializeDefaultPresets();
        }
        
        if (from < 3) {
          // Create recently read table in version 3
          await migrator.createTable(recentlyReadEntries);
        }
        
        if (from < 4) {
          // Create Quran tables in version 4
          await migrator.createTable(quranDataTable);
          await migrator.createTable(surahTable);
          await migrator.createTable(ayahTable);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'Deenhub',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
