// lib/models/quran_model.dart
class QuranData {
  final List<Surah> surahs;
  final Edition edition;

  QuranData({required this.surahs, required this.edition});

  factory QuranData.fromJson(Map<String, dynamic> json) {
    return QuranData(
      surahs: (json['surahs'] as List).map((e) => Surah.fromJson(e)).toList(),
      edition: Edition.fromJson(json['edition']),
    );
  }
}

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      revelationType: json['revelationType'],
      ayahs: (json['ayahs'] as List).map((e) => Ayah.fromJson(e)).toList(),
    );
  }
}

class Ayah {
  final int number;
  final String audio;
  final List<String> audioSecondary;
  final String text;
  final int numberInSurah;
  final int juz;
  final String textEn;
  final String textBn;
  final String transliteration;
  final AyahWordTiming? wordTiming;

  Ayah({
    required this.number,
    required this.audio,
    required this.audioSecondary,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.textEn,
    required this.textBn,
    required this.transliteration,
    this.wordTiming,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      audio: json['audio'],
      audioSecondary:
          (json['audioSecondary'] as List).map((e) => e.toString()).toList(),
      text: json['text'],
      numberInSurah: json['numberInSurah'],
      juz: json['juz'],
      textEn: json['tr_en'],
      textBn: json['tr_bn'],
      transliteration: json['transliteration'],
      wordTiming: null,
    );
  }

  Ayah copyWithWordTiming(AyahWordTiming wordTiming) {
    return Ayah(
      number: number,
      audio: audio,
      audioSecondary: audioSecondary,
      text: text,
      numberInSurah: numberInSurah,
      juz: juz,
      textEn: textEn,
      textBn: textBn,
      transliteration: transliteration,
      wordTiming: wordTiming,
    );
  }
}

class Edition {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String type;

  Edition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
  });

  factory Edition.fromJson(Map<String, dynamic> json) {
    return Edition(
      identifier: json['identifier'],
      language: json['language'],
      name: json['name'],
      englishName: json['englishName'],
      format: json['format'],
      type: json['type'],
    );
  }
}

class AyahWordTiming {
  final int surahNumber;
  final int ayahNumber;
  final List<WordSegment> segments;
  final TimingStats stats;

  AyahWordTiming({
    required this.surahNumber,
    required this.ayahNumber,
    required this.segments,
    required this.stats,
  });

  factory AyahWordTiming.fromJson(Map<String, dynamic> json) {
    return AyahWordTiming(
      surahNumber: json['surah'],
      ayahNumber: json['ayah'],
      segments: (json['segments'] as List)
          .map((segment) => WordSegment.fromJson(segment))
          .toList(),
      stats: TimingStats.fromJson(json['stats']),
    );
  }
}

class WordSegment {
  final int wordStartIndex;
  final int wordEndIndex;
  final int startMsec;
  final int endMsec;

  WordSegment({
    required this.wordStartIndex,
    required this.wordEndIndex,
    required this.startMsec,
    required this.endMsec,
  });

  factory WordSegment.fromJson(List<dynamic> json) {
    return WordSegment(
      wordStartIndex: json[0],
      wordEndIndex: json[1],
      startMsec: json[2],
      endMsec: json[3],
    );
  }
}

class TimingStats {
  final int insertions;
  final int deletions;
  final int transpositions;

  TimingStats({
    required this.insertions,
    required this.deletions,
    required this.transpositions,
  });

  factory TimingStats.fromJson(Map<String, dynamic> json) {
    return TimingStats(
      insertions: json['insertions'],
      deletions: json['deletions'],
      transpositions: json['transpositions'],
    );
  }
}
