import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/main.dart';

/// Modern daily goals notification service using the centralized NotificationManager
class DailyGoalsNotificationService {
  // Singleton implementation
  static DailyGoalsNotificationService? _instance;
  factory DailyGoalsNotificationService() => _instance ??= DailyGoalsNotificationService._internal();
  DailyGoalsNotificationService._internal();

  final NotificationManager _notificationManager = NotificationManager();

  /// Initialize the daily goals notification service
  Future<void> initialize() async {
    logger.i('Initializing Daily Goals Notification Service...');
    
    // Ensure notification manager is initialized
    if (!_notificationManager.isInitialized) {
      await _notificationManager.initialize();
    }
    
    // Schedule daily motivation
    await _scheduleDailyMotivation();
    
    // Schedule progress check
    await _scheduleProgressCheck();
    
    logger.i('Daily Goals Notification Service initialized successfully');
  }

  /// Schedule goal reminder notification
  Future<void> scheduleGoalReminder({
    required String goalId,
    required String goalTitle,
    required String goalIcon,
    required TimeOfDay reminderTime,
    List<int> reminderDays = const [1, 2, 3, 4, 5, 6, 7], // All days by default
    String? customMessage,
  }) async {
    try {
      // Cancel existing reminders for this goal
      await cancelGoalReminders(goalId);

      final message = customMessage ?? _getRandomReminderMessage(goalTitle, goalIcon);
      
      // Schedule recurring daily reminder
      final today = DateTime.now();
      var scheduleDate = DateTime(
        today.year,
        today.month,
        today.day,
        reminderTime.hour,
        reminderTime.minute,
      );
      
      // If time has passed today, schedule for tomorrow
      if (scheduleDate.isBefore(today)) {
        scheduleDate = scheduleDate.add(const Duration(days: 1));
      }

      await _notificationManager.scheduleNotification(
        type: NotificationType.dailyGoalReminder,
        title: '$goalIcon $goalTitle Reminder',
        body: message,
        scheduledDate: scheduleDate,
        payload: json.encode({
          'type': 'goal_reminder',
          'goalId': goalId,
          'goalTitle': goalTitle,
          'goalIcon': goalIcon,
        }),
      );

      logger.i('Scheduled goal reminder for $goalTitle at ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      logger.e('Error scheduling goal reminder: $e');
    }
  }

  /// Cancel goal reminders
  Future<void> cancelGoalReminders(String goalId) async {
    try {
      await _notificationManager.cancelNotification(NotificationType.dailyGoalReminder);
      logger.d('Cancelled goal reminders for $goalId');
    } catch (e) {
      logger.e('Error cancelling goal reminders: $e');
    }
  }

  /// Show goal completion notification
  Future<void> showGoalCompletionNotification({
    required String goalId,
    required String goalTitle,
    required String goalIcon,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? _getRandomCompletionMessage(goalTitle);
      
      await _notificationManager.showNotification(
        type: NotificationType.goalCompletion,
        title: '🎉 Goal Completed!',
        body: message,
        payload: json.encode({
          'type': 'goal_completion',
          'goalId': goalId,
          'goalTitle': goalTitle,
          'goalIcon': goalIcon,
        }),
      );

      logger.i('Showed goal completion notification for $goalTitle');
    } catch (e) {
      logger.e('Error showing goal completion notification: $e');
    }
  }

  /// Schedule daily motivation notification
  Future<void> _scheduleDailyMotivation() async {
    try {
      // Cancel existing motivation notification
      await _notificationManager.cancelNotification(NotificationType.dailyMotivation);

      final now = DateTime.now();
      var scheduleTime = DateTime(now.year, now.month, now.day, 7, 0); // 7:00 AM
      
      // If 7 AM has passed today, schedule for tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      await _notificationManager.scheduleNotification(
        type: NotificationType.dailyMotivation,
        title: '🌅 Good Morning!',
        body: _getRandomMotivationalMessage(),
        scheduledDate: scheduleTime,
        payload: json.encode({'type': 'motivation'}),
      );

      logger.i('Scheduled daily motivation notification for $scheduleTime');
    } catch (e) {
      logger.e('Error scheduling daily motivation: $e');
    }
  }

  /// Schedule progress check notification
  Future<void> _scheduleProgressCheck() async {
    try {
      // Cancel existing progress check
      await _notificationManager.cancelNotification(NotificationType.progressCheck);

      final now = DateTime.now();
      var scheduleTime = DateTime(now.year, now.month, now.day, 21, 0); // 9:00 PM
      
      // If 9 PM has passed today, schedule for tomorrow
      if (scheduleTime.isBefore(now)) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }

      await _notificationManager.scheduleNotification(
        type: NotificationType.progressCheck,
        title: '📊 Daily Check-in',
        body: 'How did your spiritual goals go today? Review your progress and plan for tomorrow.',
        scheduledDate: scheduleTime,
        payload: json.encode({'type': 'progress_check'}),
      );

      logger.i('Scheduled progress check notification for $scheduleTime');
    } catch (e) {
      logger.e('Error scheduling progress check: $e');
    }
  }

  /// Show streak milestone notification
  Future<void> showStreakMilestoneNotification({
    required int streakCount,
    required String goalType,
  }) async {
    try {
      if (!_isStreakMilestone(streakCount)) return;

      final message = _getStreakMilestoneMessage(streakCount, goalType);
      
      await _notificationManager.showNotification(
        type: NotificationType.streakMilestone,
        title: '🔥 Streak Milestone!',
        body: message,
        payload: json.encode({
          'type': 'streak_milestone',
          'streakCount': streakCount,
          'goalType': goalType,
        }),
      );

      logger.i('Showed streak milestone notification for $streakCount days');
    } catch (e) {
      logger.e('Error showing streak milestone notification: $e');
    }
  }

  /// Schedule weekly goal review
  Future<void> scheduleWeeklyGoalReview() async {
    try {
      // Cancel existing weekly review
      await _notificationManager.cancelNotification(NotificationType.weeklyReview);

      final now = DateTime.now();
      // Schedule for Sunday at 8:00 PM
      var scheduleTime = DateTime(now.year, now.month, now.day, 20, 0);
      
      // Find next Sunday
      while (scheduleTime.weekday != DateTime.sunday) {
        scheduleTime = scheduleTime.add(const Duration(days: 1));
      }
      
      // If we're on Sunday and it's past 8 PM, schedule for next Sunday
      if (now.weekday == DateTime.sunday && now.hour >= 20) {
        scheduleTime = scheduleTime.add(const Duration(days: 7));
      }

      await _notificationManager.scheduleNotification(
        type: NotificationType.weeklyReview,
        title: '📅 Weekly Review',
        body: 'Time to reflect on your spiritual journey this week. Review your goals and set intentions for the coming week.',
        scheduledDate: scheduleTime,
        payload: json.encode({'type': 'weekly_review'}),
      );

      logger.i('Scheduled weekly review notification for $scheduleTime');
    } catch (e) {
      logger.e('Error scheduling weekly review: $e');
    }
  }

  /// Cancel all daily goals notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationManager.cancelNotification(NotificationType.dailyMotivation);
      await _notificationManager.cancelNotification(NotificationType.progressCheck);
      await _notificationManager.cancelNotification(NotificationType.weeklyReview);
      await _notificationManager.cancelNotification(NotificationType.dailyGoalReminder);
      
      logger.i('Cancelled all daily goals notifications');
    } catch (e) {
      logger.e('Error cancelling all notifications: $e');
    }
  }

  /// Check if streak count is a milestone
  bool _isStreakMilestone(int streakCount) {
    const milestones = [3, 7, 14, 21, 30, 50, 100];
    return milestones.contains(streakCount);
  }

  /// Get random reminder message
  String _getRandomReminderMessage(String goalTitle, String goalIcon) {
    final messages = [
      'Time to work on your spiritual goal: $goalTitle $goalIcon',
      'Don\'t forget your daily practice: $goalTitle $goalIcon',
      'A gentle reminder for: $goalTitle $goalIcon',
      'Let\'s continue your spiritual journey: $goalTitle $goalIcon',
      'Time for some spiritual growth: $goalTitle $goalIcon',
      'Your daily dose of spirituality awaits: $goalTitle $goalIcon',
      'May Allah make it easy for you: $goalTitle $goalIcon',
      'Small steps, big rewards: $goalTitle $goalIcon',
    ];
    
    return messages[Random().nextInt(messages.length)];
  }

  /// Get random completion message
  String _getRandomCompletionMessage(String goalTitle) {
    final messages = [
      'Alhamdulillah! You completed "$goalTitle". May Allah reward you!',
      'Masha Allah! Great job completing "$goalTitle"!',
      'Well done! "$goalTitle" is complete. May Allah accept your efforts!',
      'Congratulations on completing "$goalTitle"! Keep up the great work!',
      'Subhan Allah! You\'ve finished "$goalTitle". May Allah bless you!',
      'Amazing! "$goalTitle" completed. Your consistency is inspiring!',
      'Barakallahu feeki! "$goalTitle" achieved successfully!',
      'Excellent work on "$goalTitle"! May Allah multiply your rewards!',
    ];
    
    return messages[Random().nextInt(messages.length)];
  }

  /// Get random motivational message
  String _getRandomMotivationalMessage() {
    final messages = [
      'Start your day with Allah\'s remembrance. Check your daily goals! 🌅',
      'A new day, a new opportunity for spiritual growth. Let\'s begin! ✨',
      'May Allah bless your day. Don\'t forget your spiritual goals! 🤲',
      'Good morning! Your spiritual journey continues today. 🌟',
      'Begin with Bismillah and achieve your daily goals! 🕌',
      'Rise and shine! Your spiritual goals are waiting for you. 📿',
      'A blessed morning to you! Time to nurture your soul. 🌸',
      'May this day bring you closer to Allah. Check your goals! ☀️',
    ];
    
    return messages[Random().nextInt(messages.length)];
  }

  /// Get streak milestone message
  String _getStreakMilestoneMessage(int streakCount, String goalType) {
    final goalTypeEmoji = _getGoalTypeEmoji(goalType);
    
    if (streakCount == 3) {
      return 'Amazing! You\'ve maintained your $goalType goal for 3 days straight! $goalTypeEmoji Keep it up!';
    } else if (streakCount == 7) {
      return 'Subhan Allah! A whole week of consistent $goalType! $goalTypeEmoji You\'re building a beautiful habit!';
    } else if (streakCount == 14) {
      return 'Masha Allah! Two weeks of dedication to $goalType! $goalTypeEmoji Your commitment is inspiring!';
    } else if (streakCount == 21) {
      return 'Incredible! 21 days of $goalType consistency! $goalTypeEmoji You\'re forming a strong spiritual habit!';
    } else if (streakCount == 30) {
      return 'Alhamdulillah! A full month of $goalType dedication! $goalTypeEmoji May Allah accept and multiply your efforts!';
    } else if (streakCount == 50) {
      return 'Outstanding! 50 days of unwavering commitment to $goalType! $goalTypeEmoji You\'re truly dedicated!';
    } else if (streakCount == 100) {
      return 'Subhan Allah! 100 days of consistent $goalType! $goalTypeEmoji This is a remarkable achievement! May Allah reward you immensely!';
    }
    
    return 'Amazing streak of $streakCount days for $goalType! $goalTypeEmoji Keep up the excellent work!';
  }

  /// Get emoji for goal type
  String _getGoalTypeEmoji(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'prayer':
        return '🕌';
      case 'quranreading':
        return '📖';
      case 'dhikr':
        return '📿';
      case 'duarecitation':
        return '🤲';
      case 'sadaqah':
        return '💝';
      case 'fasting':
        return '🌙';
      default:
        return '⭐';
    }
  }

  /// Test notification functionality
  Future<void> testNotification() async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.test,
        title: 'Test Daily Goals Notification',
        body: 'Daily goals notification system is working correctly!',
        payload: json.encode({'type': 'test'}),
      );
      logger.i('Test notification sent successfully');
    } catch (e) {
      logger.e('Error sending test notification: $e');
    }
  }
} 