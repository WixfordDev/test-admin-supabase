import 'dart:convert';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/services.dart';
import 'package:deenhub/core/services/database/app_database.dart';
import 'package:deenhub/features/quran/domain/models/quran_model.dart';

class QuranRepository {
  final AppDatabase _database;

  QuranRepository(this._database);

  Future<bool> isQuranDataSaved() async {
    return await _database.quranDao.isQuranDataSaved();
  }

  Future<void> saveQuranData(QuranData quranData) async {
    await _database.quranDao.saveQuranData(quranData);
  }

  Future<QuranData?> getQuranData() async {
    logger.d("Getting Quran data from Drift database");
    try {
      final quranData = await _database.quranDao.getQuranData();
      logger.d("Successfully retrieved Quran data: ${quranData != null}");
      return quranData;
    } catch (e) {
      logger.e("Error getting Quran data: $e");
      return null;
    }
  }

  Future<Surah?> getSurahByNumber(int surahNumber) async {
    try {
      return await _database.quranDao.getSurahByNumber(surahNumber);
    } catch (e) {
      logger.e("Error getting Surah $surahNumber: $e");
      return null;
    }
  }

  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    try {
      return await _database.quranDao.getAyah(surahNumber, ayahNumber);
    } catch (e) {
      logger.e("Error getting Ayah $surahNumber:$ayahNumber: $e");
      return null;
    }
  }

  Future<List<Surah>> getAllSurahs() async {
    try {
      return await _database.quranDao.getAllSurahs();
    } catch (e) {
      logger.e("Error getting all Surahs: $e");
      return [];
    }
  }

  Future<void> loadQuranFromAssets() async {
    logger.i("Loading Quran from assets...");
    try {
      final String jsonString = await rootBundle.loadString(Assets.jsonQuran);
      final jsonData = json.decode(jsonString);
      final quranData = QuranData.fromJson(jsonData['data']);
      
      await saveQuranData(quranData);
      logger.i("Successfully loaded Quran data from assets");
    } catch (e) {
      logger.e("Error loading Quran from assets: $e");
      rethrow;
    }
  }

  Future<void> clearQuranData() async {
    try {
      await _database.quranDao.clearQuranData();
      logger.i("Successfully cleared Quran data");
    } catch (e) {
      logger.e("Error clearing Quran data: $e");
      rethrow;
    }
  }
} 