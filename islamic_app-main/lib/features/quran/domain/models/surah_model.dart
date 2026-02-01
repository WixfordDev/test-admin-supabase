class SurahModel {
  final int number;
  final String name;
  final int ayahs;
  final String revelationType;

  SurahModel({
    required this.number,
    required this.name,
    required this.ayahs,
    required this.revelationType,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json["number"],
      name: json["englishName"],
      ayahs: json["numberOfAyahs"],
      revelationType: json["revelationType"],
    );
  }
}
