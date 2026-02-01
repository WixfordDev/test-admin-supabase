// lib/models/memorization_model.dart

import 'package:flutter/material.dart';

enum MemorizationStatus {
  notStarted,
  // new,
  learning,
  reviewing,
  memorized;

  Color getColor() {
    switch (this) {
      case MemorizationStatus.memorized:
        return Color(0xFF4CAF50);
      case MemorizationStatus.reviewing:
        return Color(0xFFFF9800);
      case MemorizationStatus.learning:
        return Color(0xFF2196F3);
      case MemorizationStatus.notStarted:
        return Color(0xFF9E9E9E);
    }
  }

  IconData getIcon() {
    switch (this) {
      case MemorizationStatus.memorized:
        return Icons.check_circle;
      case MemorizationStatus.reviewing:
        return Icons.refresh;
      case MemorizationStatus.learning:
        return Icons.school;
      case MemorizationStatus.notStarted:
        return Icons.circle_outlined;
    }
  }
}

extension MemorizationStatusExtension on MemorizationStatus? {
  Color getColorValue() => this?.getColor() ?? Color(0xFF9E9E9E);
  IconData getIconValue() => this?.getIcon() ?? Icons.circle_outlined;
}

class MemorizationProgress {
  final int totalVerses = 6236;
  int memorizedCount = 0;
  int reviewingCount = 0;
  int learningCount = 0;
  Map<int, Map<int, MemorizationStatus>> surahProgress = {};
  List<RecentlyRead> recentlyRead = [];

  double get overallProgress =>
      totalVerses > 0 ? memorizedCount / totalVerses * 100 : 0.0;
  int get totalInProgress => memorizedCount + reviewingCount + learningCount;

  MemorizationProgress();

  factory MemorizationProgress.fromJson(Map<String, dynamic> json) {
    final progress = MemorizationProgress();
    progress.memorizedCount = json['memorizedCount'] ?? 0;
    progress.reviewingCount = json['reviewingCount'] ?? 0;
    progress.learningCount = json['learningCount'] ?? 0;

    // Parse surah progress
    final surahProgressJson = json['surahProgress'] as Map<String, dynamic>?;
    if (surahProgressJson != null) {
      surahProgressJson.forEach((surahKey, versesMap) {
        final surahId = int.parse(surahKey);
        progress.surahProgress[surahId] = {};

        (versesMap as Map<String, dynamic>).forEach((verseKey, statusValue) {
          final verseId = int.parse(verseKey);
          progress.surahProgress[surahId]![verseId] =
              MemorizationStatus.values[statusValue as int];
        });
      });
    }

    // Parse recently read
    final recentlyReadJson = json['recentlyRead'] as List?;
    if (recentlyReadJson != null) {
      progress.recentlyRead = recentlyReadJson
          .map((item) => RecentlyRead.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return progress;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> surahProgressJson = {};

    surahProgress.forEach((surahId, verses) {
      surahProgressJson[surahId.toString()] = {};
      verses.forEach((verseId, status) {
        surahProgressJson[surahId.toString()][verseId.toString()] =
            status.index;
      });
    });

    return {
      'memorizedCount': memorizedCount,
      'reviewingCount': reviewingCount,
      'learningCount': learningCount,
      'surahProgress': surahProgressJson,
      'recentlyRead': recentlyRead.map((item) => item.toJson()).toList(),
    };
  }

  void updateVerseStatus(int surahId, int verseId, MemorizationStatus status) {
    // Initialize surah map if it doesn't exist
    surahProgress[surahId] ??= {};

    // Get old status if it exists
    final oldStatus = surahProgress[surahId]![verseId];

    // Update the status
    surahProgress[surahId]![verseId] = status;

    // Update counters
    if (oldStatus != null) {
      switch (oldStatus) {
        case MemorizationStatus.memorized:
          memorizedCount--;
          break;
        case MemorizationStatus.reviewing:
          reviewingCount--;
          break;
        case MemorizationStatus.learning:
          learningCount--;
          break;
        default:
          break;
      }
    }

    switch (status) {
      case MemorizationStatus.memorized:
        memorizedCount++;
        break;
      case MemorizationStatus.reviewing:
        reviewingCount++;
        break;
      case MemorizationStatus.learning:
        learningCount++;
        break;
      default:
        break;
    }
  }

  void addRecentlyRead(int surahId, int verseId, {String source = 'default'}) {
    // Check if already exists
    final existing = recentlyRead.indexWhere(
        (item) => item.surahId == surahId && item.verseId == verseId);

    // Remove if exists
    if (existing >= 0) {
      recentlyRead.removeAt(existing);
    }

    // Add to the beginning
    recentlyRead.insert(
        0,
        RecentlyRead(
          surahId: surahId,
          verseId: verseId,
          timestamp: DateTime.now(),
          source: source,
        ));

    // Keep only recent 10
    if (recentlyRead.length > 10) {
      recentlyRead = recentlyRead.sublist(0, 10);
    }
  }
}

class RecentlyRead {
  final int? id;
  final int surahId;
  final int verseId;
  final DateTime timestamp;
  final String source;

  RecentlyRead({
    this.id,
    required this.surahId,
    required this.verseId,
    required this.timestamp,
    this.source = 'default',
  });

  factory RecentlyRead.fromJson(Map<String, dynamic> json) {
    return RecentlyRead(
      id: json['id'],
      surahId: json['surahId'],
      verseId: json['verseId'],
      timestamp: DateTime.parse(json['timestamp']),
      source: json['source'] ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'surahId': surahId,
      'verseId': verseId,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
    };
  }
}
