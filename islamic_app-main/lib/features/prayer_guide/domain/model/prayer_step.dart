class PrayerStep {
  final String title;
  final String description;
  final String? imagePath;
  final String? videoPath;
  final List<String>? subSteps;

  const PrayerStep({
    required this.title,
    required this.description,
    this.imagePath,
    this.videoPath,
    this.subSteps,
  });
}

class PrayerSection {
  final String title;
  final String description;
  final List<PrayerStep> steps;
  final String? image;

  const PrayerSection({
    required this.title,
    required this.description,
    required this.steps,
    this.image,
  });
}

class Prayer {
  final String name;
  final String arabicName;
  final String description;
  final int rakats;
  final bool isFard;
  final List<String>? virtues;

  const Prayer({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.rakats,
    required this.isFard,
    this.virtues,
  });
}

class DetailedPrayer {
  final String name;
  final String arabicName;
  final String description;
  final int fardRakats;
  final int sunnahBefore;
  final int sunnahAfter;
  final int witr;
  final bool isFard;
  final String timeDescription;
  final List<String> virtues;
  final bool isSpecial;

  const DetailedPrayer({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.fardRakats,
    this.sunnahBefore = 0,
    this.sunnahAfter = 0,
    this.witr = 0,
    required this.isFard,
    required this.timeDescription,
    this.virtues = const [],
    this.isSpecial = false,
  });
} 