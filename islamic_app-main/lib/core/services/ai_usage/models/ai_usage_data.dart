
class AIUsageData {
  final String? lastUsed;
  final int monthlyTokens;
  final int totalRequests;
  final String lastResetDate;

  const AIUsageData({
    this.lastUsed,
    required this.monthlyTokens,
    required this.totalRequests,
    required this.lastResetDate,
  });

  Map<String, dynamic> toJson() => {
        'lastUsed': lastUsed,
        'monthlyTokens': monthlyTokens,
        'totalRequests': totalRequests,
        'lastResetDate': lastResetDate,
      };

  factory AIUsageData.fromJson(Map<String, dynamic> json) => AIUsageData(
        lastUsed: json['lastUsed'] as String?,
        monthlyTokens: json['monthlyTokens'] as int? ?? 0,
        totalRequests: json['totalRequests'] as int? ?? 0,
        lastResetDate: json['lastResetDate'] as String? ?? DateTime.now().toIso8601String(),
      );

  AIUsageData copyWith({
    String? lastUsed,
    int? monthlyTokens,
    int? totalRequests,
    String? lastResetDate,
  }) {
    return AIUsageData(
      lastUsed: lastUsed ?? this.lastUsed,
      monthlyTokens: monthlyTokens ?? this.monthlyTokens,
      totalRequests: totalRequests ?? this.totalRequests,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIUsageData &&
        other.lastUsed == lastUsed &&
        other.monthlyTokens == monthlyTokens &&
        other.totalRequests == totalRequests &&
        other.lastResetDate == lastResetDate;
  }

  @override
  int get hashCode {
    return lastUsed.hashCode ^
        monthlyTokens.hashCode ^
        totalRequests.hashCode ^
        lastResetDate.hashCode;
  }
}
