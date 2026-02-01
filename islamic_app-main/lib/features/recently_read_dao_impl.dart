import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:deenhub/core/services/database/app_database.dart';

/// Helper class to migrate data from the old SQLite database to the new Drift database
class RecentlyReadDataMigrator {
  static final RecentlyReadDataMigrator _instance = RecentlyReadDataMigrator._internal();
  factory RecentlyReadDataMigrator() => _instance;
  RecentlyReadDataMigrator._internal();
  
  /// Check if migration is needed and migrate data if necessary
  Future<void> migrateIfNeeded(AppDatabase driftDb) async {
    try {
      // Check if the old database file exists
      final dbPath = await getApplicationDocumentsDirectory();
      final path = join(dbPath.path, 'quran.db');
      
      final exists = await databaseExists(path);
      if (!exists) {
        debugPrint('Old database does not exist, no migration needed');
        return;
      }
      
      // Open the old database
      final oldDb = await openDatabase(path);
      
      // Check if the recently_read table exists
      final tables = await oldDb.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'recently_read'],
      );
      
      if (tables.isEmpty) {
        debugPrint('Old database does not have recently_read table, no migration needed');
        await oldDb.close();
        return;
      }
      
      // Get all data from the old database
      final entries = await oldDb.query('recently_read');
      
      if (entries.isEmpty) {
        debugPrint('No data to migrate');
        await oldDb.close();
        return;
      }
      
      debugPrint('Migrating ${entries.length} entries from SQLite to Drift');
      
      // Insert all entries into the new database
      for (final entry in entries) {
        await driftDb.recentlyReadDao.recordRecentlyRead(
          entry['surah_id'] as int,
          entry['verse_id'] as int,
          source: entry['source'] as String? ?? 'default',
        );
      }
      
      debugPrint('Migration completed successfully');
      
      // Close the old database
      await oldDb.close();
      
      // Optionally, rename or delete the old database file after migration
      // await File(path).rename(join(dbPath.path, 'quran_backup.db'));
    } catch (e) {
      debugPrint('Error during migration: $e');
    }
  }
} 