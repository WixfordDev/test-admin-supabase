import 'package:drift/drift.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/core/services/database/tables/recently_read_tables.dart';

part 'recently_read_dao.g.dart';

@DriftAccessor(tables: [RecentlyReadEntries])
class RecentlyReadDao extends DatabaseAccessor<AppDatabase> with _$RecentlyReadDaoMixin {
  RecentlyReadDao(super.db);

  // Get recently read verses
  Future<List<RecentlyReadEntry>> getRecentlyRead({String? source, int limit = 10}) {
    final query = select(recentlyReadEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
      ..limit(limit);
    
    if (source != null) {
      query.where((t) => t.source.equals(source));
    }
    
    return query.get();
  }
  
  // Record a recently read verse
  Future<int> recordRecentlyRead(int surahId, int verseId, {String source = 'default'}) async {
    // Check if the entry already exists
    final query = select(recentlyReadEntries)
      ..where((t) => t.surahId.equals(surahId) & t.verseId.equals(verseId));
      
    final existing = await query.get();
    
    if (existing.isNotEmpty) {
      // Update existing entry
      return (update(recentlyReadEntries)
        ..where((t) => t.id.equals(existing.first.id)))
        .write(RecentlyReadEntriesCompanion(
          timestamp: Value(DateTime.now()),
          source: Value(source),
        ));
    } else {
      // Insert new entry
      return into(recentlyReadEntries).insert(
        RecentlyReadEntriesCompanion.insert(
          surahId: surahId,
          verseId: verseId,
          source: Value(source),
        ),
      );
    }
  }
  
  // Delete old entries to keep the table size manageable
  Future<void> cleanupOldEntries(int keepCount) async {
    // Get all entries in timestamp descending order
    final allEntries = await (select(recentlyReadEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
      .get();
    
    if (allEntries.length > keepCount) {
      // Get IDs of entries to delete
      final entriesToDelete = allEntries.sublist(keepCount);
      
      // Delete entries
      for (final entry in entriesToDelete) {
        await (delete(recentlyReadEntries)..where((t) => t.id.equals(entry.id))).go();
      }
    }
  }
} 