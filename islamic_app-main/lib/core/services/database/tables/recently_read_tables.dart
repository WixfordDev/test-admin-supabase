import 'package:drift/drift.dart';

// Recently Read Quran Verses Table
class RecentlyReadEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahId => integer()();
  IntColumn get verseId => integer()();
  TextColumn get source => text().withDefault(const Constant('default'))(); // reading_mode, verse_view, etc.
  DateTimeColumn get timestamp => dateTime().withDefault(Constant(DateTime.now()))();
} 