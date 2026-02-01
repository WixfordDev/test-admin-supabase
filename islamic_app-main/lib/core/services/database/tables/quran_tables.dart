import 'package:drift/drift.dart';

// Quran data table to store Quran edition information
class QuranDataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get identifier => text()();
  TextColumn get language => text()();
  TextColumn get name => text()();
  TextColumn get englishName => text()();
  TextColumn get format => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
}

// Surah table to store Quran chapters
class SurahTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get number => integer()();
  TextColumn get name => text()();
  TextColumn get englishName => text()();
  TextColumn get englishNameTranslation => text()();
  TextColumn get revelationType => text()();
  IntColumn get quranDataId => integer().references(QuranDataTable, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
}

// Ayah table to store Quran verses
class AyahTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get number => integer()();
  TextColumn get audio => text()();
  TextColumn get audioSecondary => text()(); // JSON string array
  TextColumn get textAr => text()(); // Arabic text
  IntColumn get numberInSurah => integer()();
  IntColumn get juz => integer()();
  TextColumn get textEn => text()();
  TextColumn get textBn => text()();
  TextColumn get transliteration => text()();
  IntColumn get surahId => integer().references(SurahTable, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();
} 