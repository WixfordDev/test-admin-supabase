class VerseModel {
  final int number;
  final String text;

  VerseModel({
    required this.number,
    required this.text,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      number: json["number"],
      text: json["text"],
    );
  }
}
