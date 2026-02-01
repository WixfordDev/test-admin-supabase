class AIConfigData {
  final String apiKey;
  final String modelName;
  final bool forceRefresh;
  final int monthlyTokenLimit;
  final int maxCompletionTokens;

  const AIConfigData({
    required this.apiKey,
    required this.modelName,
    required this.forceRefresh,
    required this.monthlyTokenLimit,
    required this.maxCompletionTokens,
  });

  Map<String, dynamic> toJson() => {
    'apiKey': apiKey,
    'modelName': modelName,
    'forceRefresh': forceRefresh,
    'monthlyTokenLimit': monthlyTokenLimit,
    'maxCompletionTokens': maxCompletionTokens,
  };

  factory AIConfigData.fromJson(Map<String, dynamic> json) => AIConfigData(
    apiKey: json['apiKey'] as String? ?? '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',
    modelName: json['modelName'] as String? ?? 'gpt-5-mini',
    forceRefresh: json['forceRefresh'] as bool? ?? false,
    monthlyTokenLimit: json['monthlyTokenLimit'] as int? ?? 0,
    maxCompletionTokens: json['maxCompletionTokens'] as int? ?? 0,
  );

  AIConfigData copyWith({
    String? apiKey,
    String? modelName,
    bool? forceRefresh,
    int? monthlyTokenLimit,
    int? maxCompletionTokens,
  }) {
    return AIConfigData(
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      forceRefresh: forceRefresh ?? this.forceRefresh,
      monthlyTokenLimit: monthlyTokenLimit ?? this.monthlyTokenLimit,
      maxCompletionTokens: maxCompletionTokens ?? this.maxCompletionTokens,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIConfigData &&
        other.apiKey == apiKey &&
        other.modelName == modelName &&
        other.forceRefresh == forceRefresh &&
        other.monthlyTokenLimit == monthlyTokenLimit &&
        other.maxCompletionTokens == maxCompletionTokens;
  }

  @override
  int get hashCode {
    return apiKey.hashCode ^
        modelName.hashCode ^
        forceRefresh.hashCode ^
        monthlyTokenLimit.hashCode ^
        maxCompletionTokens.hashCode;
  }
}
