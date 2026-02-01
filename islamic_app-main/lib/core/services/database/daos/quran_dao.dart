import 'package:drift/drift.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/core/services/database/tables/quran_tables.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';
import 'dart:convert';

part 'quran_dao.g.dart';

@DriftAccessor(tables: [QuranDataTable, SurahTable, AyahTable])
class QuranDao extends DatabaseAccessor<AppDatabase> with _$QuranDaoMixin {
  QuranDao(super.db);

  // Check if Quran data exists
  Future<bool> isQuranDataSaved() async {
    final results = await select(quranDataTable).get();
    return results.isNotEmpty;
  }

  // Save complete Quran data
  Future<void> saveQuranData(QuranData quranData) async {
    await transaction(() async {
      // Insert QuranData
      final quranDataId = await into(quranDataTable).insert(
        QuranDataTableCompanion.insert(
          identifier: quranData.edition.identifier,
          language: quranData.edition.language,
          name: quranData.edition.name,
          englishName: quranData.edition.englishName,
          format: quranData.edition.format,
          type: quranData.edition.type,
        ),
      );

      // Insert Surahs and Ayahs
      for (final surah in quranData.surahs) {
        final surahId = await into(surahTable).insert(
          SurahTableCompanion.insert(
            number: surah.number,
            name: surah.name,
            englishName: surah.englishName,
            englishNameTranslation: surah.englishNameTranslation,
            revelationType: surah.revelationType,
            quranDataId: quranDataId,
          ),
        );

        // Insert Ayahs for this Surah
        for (final ayah in surah.ayahs) {
          await into(ayahTable).insert(
            AyahTableCompanion.insert(
              number: ayah.number,
              audio: ayah.audio,
              audioSecondary: jsonEncode(ayah.audioSecondary),
              textAr: ayah.text,
              numberInSurah: ayah.numberInSurah,
              juz: ayah.juz,
              textEn: ayah.textEn,
              textBn: ayah.textBn,
              transliteration: ayah.transliteration,
              surahId: surahId,
            ),
          );
        }
      }
    });
  }

  // Get complete Quran data
  Future<QuranData?> getQuranData() async {
    final quranDataEntry = await (select(quranDataTable)).getSingleOrNull();
    if (quranDataEntry == null) return null;

    // Get all surahs for this Quran data
    final surahs = await (select(surahTable)
          ..where((t) => t.quranDataId.equals(quranDataEntry.id))
          ..orderBy([(t) => OrderingTerm.asc(t.number)]))
        .get();

    final surahModels = <Surah>[];
    
    for (final surah in surahs) {
      // Get ayahs for this surah
      final ayahs = await (select(ayahTable)
            ..where((t) => t.surahId.equals(surah.id))
            ..orderBy([(t) => OrderingTerm.asc(t.numberInSurah)]))
          .get();

      final ayahModels = ayahs.map((ayah) => Ayah(
        number: ayah.number,
        audio: ayah.audio,
        audioSecondary: List<String>.from(jsonDecode(ayah.audioSecondary)),
        text: ayah.textAr,
        numberInSurah: ayah.numberInSurah,
        juz: ayah.juz,
        textEn: ayah.textEn,
        textBn: ayah.textBn,
        transliteration: ayah.transliteration,
      )).toList();

      surahModels.add(Surah(
        number: surah.number,
        name: surah.name,
        englishName: surah.englishName,
        englishNameTranslation: surah.englishNameTranslation,
        revelationType: surah.revelationType,
        ayahs: ayahModels,
      ));
    }

    return QuranData(
      surahs: surahModels,
      edition: Edition(
        identifier: quranDataEntry.identifier,
        language: quranDataEntry.language,
        name: quranDataEntry.name,
        englishName: quranDataEntry.englishName,
        format: quranDataEntry.format,
        type: quranDataEntry.type,
      ),
    );
  }

  // Get specific Surah by number
  Future<Surah?> getSurahByNumber(int surahNumber) async {
    final surah = await (select(surahTable)
          ..where((t) => t.number.equals(surahNumber)))
        .getSingleOrNull();
    
    if (surah == null) return null;

    final ayahs = await (select(ayahTable)
          ..where((t) => t.surahId.equals(surah.id))
          ..orderBy([(t) => OrderingTerm.asc(t.numberInSurah)]))
        .get();

    final ayahModels = ayahs.map((ayah) => Ayah(
      number: ayah.number,
      audio: ayah.audio,
      audioSecondary: List<String>.from(jsonDecode(ayah.audioSecondary)),
      text: ayah.textAr,
      numberInSurah: ayah.numberInSurah,
      juz: ayah.juz,
      textEn: ayah.textEn,
      textBn: ayah.textBn,
      transliteration: ayah.transliteration,
    )).toList();

    return Surah(
      number: surah.number,
      name: surah.name,
      englishName: surah.englishName,
      englishNameTranslation: surah.englishNameTranslation,
      revelationType: surah.revelationType,
      ayahs: ayahModels,
    );
  }

  // Get specific Ayah by surah and ayah number
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final query = select(ayahTable).join([
      innerJoin(surahTable, surahTable.id.equalsExp(ayahTable.surahId)),
    ]);

    query.where(surahTable.number.equals(surahNumber) & 
                ayahTable.numberInSurah.equals(ayahNumber));

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    final ayah = result.readTable(ayahTable);
    return Ayah(
      number: ayah.number,
      audio: ayah.audio,
      audioSecondary: List<String>.from(jsonDecode(ayah.audioSecondary)),
      text: ayah.textAr,
      numberInSurah: ayah.numberInSurah,
      juz: ayah.juz,
      textEn: ayah.textEn,
      textBn: ayah.textBn,
      transliteration: ayah.transliteration,
    );
  }

  // Get all Surahs with basic info (without ayahs)
  Future<List<Surah>> getAllSurahs() async {
    final surahs = await (select(surahTable)
          ..orderBy([(t) => OrderingTerm.asc(t.number)]))
        .get();

    return surahs.map((surah) => Surah(
      number: surah.number,
      name: surah.name,
      englishName: surah.englishName,
      englishNameTranslation: surah.englishNameTranslation,
      revelationType: surah.revelationType,
      ayahs: [], // Empty for basic info
    )).toList();
  }

  // Clear all Quran data
  Future<void> clearQuranData() async {
    await transaction(() async {
      await delete(ayahTable).go();
      await delete(surahTable).go();
      await delete(quranDataTable).go();
    });
  }
} 