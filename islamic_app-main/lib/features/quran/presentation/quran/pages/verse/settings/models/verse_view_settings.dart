class VerseViewSettings {
  bool showTransliteration;
  bool showTranslation;
  bool showRepeatButton;
  bool showSpeedControls;
  bool showMemorizationStatus;
  bool showAiExplanation;

  VerseViewSettings({
    this.showTransliteration = true,
    this.showTranslation = true,
    this.showRepeatButton = true,
    this.showSpeedControls = true,
    this.showMemorizationStatus = true,
    this.showAiExplanation = true,
  });

  factory VerseViewSettings.fromJson(Map<String, dynamic> json) {
    return VerseViewSettings(
      showTransliteration: json['showTransliteration'] ?? true,
      showTranslation: json['showTranslation'] ?? true,
      showRepeatButton: json['showRepeatButton'] ?? true,
      showSpeedControls: json['showSpeedControls'] ?? true,
      showMemorizationStatus: json['showMemorizationStatus'] ?? true,
      showAiExplanation: json['showAiExplanation'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showTransliteration': showTransliteration,
      'showTranslation': showTranslation,
      'showRepeatButton': showRepeatButton,
      'showSpeedControls': showSpeedControls,
      'showMemorizationStatus': showMemorizationStatus,
      'showAiExplanation': showAiExplanation,
    };
  }

  VerseViewSettings copyWith({
    bool? showTransliteration,
    bool? showTranslation,
    bool? showRepeatButton,
    bool? showSpeedControls,
    bool? showMemorizationStatus,
    bool? showAiExplanation,
  }) {
    return VerseViewSettings(
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      showRepeatButton: showRepeatButton ?? this.showRepeatButton,
      showSpeedControls: showSpeedControls ?? this.showSpeedControls,
      showMemorizationStatus: showMemorizationStatus ?? this.showMemorizationStatus,
      showAiExplanation: showAiExplanation ?? this.showAiExplanation,
    );
  }
}
