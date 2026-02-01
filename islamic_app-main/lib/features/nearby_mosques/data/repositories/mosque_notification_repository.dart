import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:deenhub/main.dart';

/// Repository for handling mosque notification data operations
///
/// This repository works with the adjustment-based approach where:
/// 1. Prayer times are calculated in the app using astronomical formulas
/// 2. Mosque-specific adjustments are stored in the database
/// 3. The app applies these adjustments to the calculated times
class MosqueNotificationRepository {
  final SupabaseClient _supabase;

  MosqueNotificationRepository({required SupabaseClient supabase}) : _supabase = supabase;

  // REMOVED: User-specific subscription methods - favorites are now stored locally
  // REMOVED: getSubscribedMosques, subscribeMosque, unsubscribeMosque, getPendingNotifications
  
  /// Get time changes for notification checking (app will filter by local favorites)
  Future<List<Map<String, dynamic>>> getMosqueTimeChangesSince(DateTime? since) async {
    final response = await _supabase
        .rpc('get_mosque_time_changes_since', params: {
          'since_timestamp': since?.toIso8601String(),
        });
    
    return List<Map<String, dynamic>>.from(response as List);
  }
  
  /// Get recent significant time changes (for general monitoring)
  Future<List<Map<String, dynamic>>> getRecentSignificantTimeChanges({int hoursBack = 24}) async {
    final response = await _supabase
        .rpc('get_recent_significant_time_changes', params: {
          'hours_back': hoursBack,
        });
    
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Mark notifications as sent for a user
  Future<int> markNotificationsAsSent(List<int> notificationIds) async {
    final response = await _supabase
        .rpc('mark_mosque_notifications_sent', params: {
          'notification_ids': notificationIds,
        });
    
    return response as int;
  }

  /// Update mosque prayer time adjustment with coordinates for FCM notification
  ///
  /// This updates the adjustment minutes for a specific prayer at a mosque
  /// and triggers an FCM notification with mosque coordinates.
  Future<void> updateMosquePrayerTime({
    required String mosqueId,
    required String mosqueName,
    required double mosqueLatitude,
    required double mosqueLongitude,
    required String prayerName,
    required String timeType, // 'adhan' or 'iqamah'
    required int adjustmentMinutes,
    String changeSource = 'user', // 'user' or 'prediction'
    DateTime? effectiveDate,
    String? changedBy,
    String? notes,
    // Optional parameter for clearing cache in the MosqueRepository to ensure changes propagate
    Function(String)? onMosqueAdjustmentUpdated,
  }) async {
    // Validate input parameters
    if (mosqueId.isEmpty || mosqueName.isEmpty || prayerName.isEmpty) {
      throw ArgumentError('Required parameters cannot be empty');
    }

    if (!['adhan', 'iqamah'].contains(timeType.toLowerCase())) {
      throw ArgumentError('timeType must be either "adhan" or "iqamah"');
    }

    if (!['user', 'prediction'].contains(changeSource.toLowerCase())) {
      throw ArgumentError('changeSource must be either "user" or "prediction"');
    }

    final adjustmentData = {
      'mosque_id': mosqueId,
      'prayer_name': prayerName.toLowerCase().trim(),
      'time_type': timeType.toLowerCase().trim(),
      'adjustment_minutes': adjustmentMinutes,
      'change_source': changeSource.toLowerCase(),
      'effective_date': (effectiveDate ?? DateTime.now()).toIso8601String().split('T')[0], // Date only
    };

    // Add optional fields if provided
    if (changedBy != null && changedBy.isNotEmpty) {
      adjustmentData['changed_by'] = changedBy.trim();
    }
    if (notes != null && notes.isNotEmpty) {
      adjustmentData['notes'] = notes.trim();
    }

    // Get previous adjustment for notification comparison
    int? previousAdjustment;
    try {
      final previousData = await _supabase
          .from('mosque_adjustments')
          .select('adjustment_minutes')
          .eq('mosque_id', mosqueId)
          .eq('prayer_name', prayerName.toLowerCase().trim())
          .eq('time_type', timeType.toLowerCase().trim())
          .maybeSingle();

      if (previousData != null) {
        previousAdjustment = previousData['adjustment_minutes'] as int?;
      }

      logger.d('Previous adjustment for $mosqueId $prayerName $timeType: $previousAdjustment');
    } catch (e) {
      logger.w('Could not get previous adjustment: $e');
    }

    try {
      // Save adjustment to database
      await _supabase
          .from('mosque_adjustments')
          .upsert(
            adjustmentData,
            onConflict: 'mosque_id,prayer_name,time_type',
            ignoreDuplicates: false,
          );

      logger.i('Mosque adjustment saved: $mosqueId $prayerName $timeType: ${adjustmentMinutes}min (was: ${previousAdjustment ?? 'none'})');

      // Clear cache for this mosque to ensure immediate updates for all users
      if (onMosqueAdjustmentUpdated != null) {
        onMosqueAdjustmentUpdated(mosqueId);
      }

      // Manually trigger FCM notification with mosque coordinates
      await _sendFcmNotification(
        mosqueId: mosqueId,
        mosqueName: mosqueName,
        mosqueLatitude: mosqueLatitude,
        mosqueLongitude: mosqueLongitude,
        prayerName: prayerName.toLowerCase().trim(),
        timeType: timeType.toLowerCase().trim(),
        adjustmentMinutes: adjustmentMinutes,
        previousAdjustment: previousAdjustment,
        changeSource: changeSource.toLowerCase(),
        effectiveDate: effectiveDate,
      );

    } catch (e) {
      logger.e('Database upsert failed: $e');

      // If upsert fails, try manual update approach
      try {
        logger.i('Attempting manual update approach...');

        // First try to update existing record
        final updateData = {
          'adjustment_minutes': adjustmentMinutes,
          'change_source': changeSource.toLowerCase(),
          'effective_date': adjustmentData['effective_date'],
          'updated_at': 'now()',
        };

        if (changedBy != null && changedBy.isNotEmpty) {
          updateData['changed_by'] = changedBy.trim();
        }
        if (notes != null && notes.isNotEmpty) {
          updateData['notes'] = notes.trim();
        }

        final updateResponse = await _supabase
            .from('mosque_adjustments')
            .update(updateData)
            .eq('mosque_id', mosqueId)
            .eq('prayer_name', prayerName.toLowerCase().trim())
            .eq('time_type', timeType.toLowerCase().trim())
            .select();

        // If no rows were updated, insert new record
        if (updateResponse.isEmpty) {
          await _supabase
              .from('mosque_adjustments')
              .insert(adjustmentData);
          logger.i('New adjustment record inserted');
        } else {
          logger.i('Existing adjustment record updated');
        }

        // Clear cache for this mosque to ensure immediate updates for all users
        if (onMosqueAdjustmentUpdated != null) {
          onMosqueAdjustmentUpdated(mosqueId);
        }

        // Send FCM notification even if database update had issues
        await _sendFcmNotification(
          mosqueId: mosqueId,
          mosqueName: mosqueName,
          mosqueLatitude: mosqueLatitude,
          mosqueLongitude: mosqueLongitude,
          prayerName: prayerName.toLowerCase().trim(),
          timeType: timeType.toLowerCase().trim(),
          adjustmentMinutes: adjustmentMinutes,
          previousAdjustment: previousAdjustment,
          changeSource: changeSource.toLowerCase(),
          effectiveDate: effectiveDate,
        );

      } catch (fallbackError) {
        logger.e('Failed to save mosque adjustment with fallback: $fallbackError');
        rethrow;
      }
    }
  }

  /// Send FCM notification directly with mosque coordinates
  Future<void> _sendFcmNotification({
    required String mosqueId,
    required String mosqueName,
    required double mosqueLatitude,
    required double mosqueLongitude,
    required String prayerName,
    required String timeType,
    required int adjustmentMinutes,
    int? previousAdjustment,
    required String changeSource,
    DateTime? effectiveDate,
  }) async {
    try {
      // For user changes: always send notification regardless of minutes difference
      // For system/prediction changes: only send for significant changes (≥5 minutes difference)
      if (changeSource != 'user' && 
          previousAdjustment != null && 
          (adjustmentMinutes - previousAdjustment).abs() < 5) {
        logger.d('System change not significant enough for notification: ${(adjustmentMinutes - previousAdjustment).abs()} minutes difference');
        return;
      }
      
      if (changeSource == 'user') {
        logger.d('Sending notification for user change regardless of time difference');
      }

      logger.d('Sending FCM notification for mosque: $mosqueName at ($mosqueLatitude, $mosqueLongitude)');
      logger.d('Prayer: $prayerName $timeType, Adjustment: ${adjustmentMinutes}min (was: ${previousAdjustment ?? 'none'})');

      // Prepare FCM payload with all necessary data for device-side calculation
      final fcmPayload = {
        'type': 'mosque_prayer_time_change',
        'mosque_id': mosqueId,
        'mosque_name': mosqueName,
        'mosque_latitude': mosqueLatitude.toString(),
        'mosque_longitude': mosqueLongitude.toString(),
        'prayer_name': prayerName,
        'time_type': timeType,
        'adjustment_minutes': adjustmentMinutes.toString(),
        'change_source': changeSource,
        'effective_date': (effectiveDate ?? DateTime.now()).toIso8601String().split('T')[0],
      };
      
      // Add previous adjustment if available
      if (previousAdjustment != null) {
        fcmPayload['previous_adjustment'] = previousAdjustment.toString();
      }

      logger.d('FCM payload: $fcmPayload');

      final response = await _supabase.functions.invoke(
        'fcm-mosque-notification',
        body: fcmPayload,
      );

      if (response.data != null && response.data['success'] == true) {
        logger.i('FCM notification sent successfully for mosque: $mosqueName');
        
        // Log additional details from response if available
        if (response.data['details'] != null) {
          logger.d('FCM notification details: ${response.data['details']}');
        }
      } else {
        logger.w('FCM notification response indicates failure: ${response.data}');
        
        // Log error details if available
        if (response.data != null && response.data['error'] != null) {
          logger.e('FCM notification error: ${response.data['error']}');
        }
      }

    } catch (e) {
      logger.e('Error sending FCM notification: $e');
      
      // Log stack trace for debugging
      if (e is Error) {
        logger.e('Stack trace: ${e.stackTrace}');
      }
      
      // Don't rethrow - notification failure shouldn't prevent saving the adjustment
    }
  }

  /// Get adjusted prayer time for a mosque
  /// 
  /// Returns only the adjustment value, not a calculated time.
  /// The app will calculate the base prayer time and apply this adjustment.
  Future<Map<String, dynamic>> getAdjustedPrayerTime(
    String mosqueId, 
    String prayerName, 
    {String timeType = 'adhan'}
  ) async {
    final response = await _supabase
        .rpc('get_adjusted_prayer_time', params: {
          'mosque_id_param': mosqueId,
          'prayer_name_param': prayerName.toLowerCase().trim(),
          'time_type_param': timeType.toLowerCase().trim(),
        });
    
    return response as Map<String, dynamic>;
  }

  /// Get mosque details including metadata and adjustments
  Future<Map<String, dynamic>> getMosqueDetails(String mosqueId) async {
    final response = await _supabase
        .rpc('get_mosque_details', params: {
          'mosque_id_param': mosqueId,
        });
    
    return response as Map<String, dynamic>;
  }

  /// Delete all prayer time adjustments for a mosque (reset to original times)
  /// This will delete all adjustment entries from the database and send notifications
  Future<void> resetMosqueAdjustments({
    required String mosqueId,
    required String mosqueName,
    required double mosqueLatitude,
    required double mosqueLongitude,
    String? resetBy,
    String? notes,
    bool onlyNotifyVerified = false,
    List<Map<String, dynamic>>? verifiedPrayers,
    // Optional parameter for clearing cache in the MosqueRepository to ensure changes propagate
    Function(String)? onMosqueAdjustmentUpdated,
  }) async {
    try {
      // Validate input parameters
      if (mosqueId.isEmpty || mosqueName.isEmpty) {
        throw ArgumentError('Required parameters cannot be empty');
      }

      logger.d('Resetting all adjustments for mosque: $mosqueId');

      // Get existing adjustments before deletion (for notification comparison)
      final existingAdjustments = await _supabase
          .from('mosque_adjustments')
          .select('prayer_name, time_type, adjustment_minutes')
          .eq('mosque_id', mosqueId);

      logger.d('Found ${existingAdjustments.length} existing adjustments to delete');

      // Delete all adjustment entries for this mosque
      await _supabase
          .from('mosque_adjustments')
          .delete()
          .eq('mosque_id', mosqueId);

      logger.i('Successfully deleted all adjustments for mosque: $mosqueId');

      // Clear cache for this mosque to ensure immediate updates for all users
      if (onMosqueAdjustmentUpdated != null) {
        onMosqueAdjustmentUpdated(mosqueId);
      }

      // Send FCM notifications based on onlyNotifyVerified flag
      if (onlyNotifyVerified && verifiedPrayers != null) {
        // Only send notifications for previously verified entries
        logger.d('Sending reset notifications only for ${verifiedPrayers.length} verified prayer times');
        
        for (var verifiedPrayer in verifiedPrayers) {
          final prayerName = verifiedPrayer['prayer_name'] as String;
          final timeType = verifiedPrayer['time_type'] as String;
          
          // Find the corresponding existing adjustment (if any) for previous value
          final existingAdjustment = existingAdjustments.firstWhere(
            (adj) => adj['prayer_name'] == prayerName && adj['time_type'] == timeType,
            orElse: () => <String, dynamic>{},
          );
          
          final previousAdjustment = existingAdjustment['adjustment_minutes'] as int? ?? 0;

          try {
            await _sendResetNotification(
              mosqueId: mosqueId,
              mosqueName: mosqueName,
              mosqueLatitude: mosqueLatitude,
              mosqueLongitude: mosqueLongitude,
              prayerName: prayerName,
              timeType: timeType,
              previousAdjustment: previousAdjustment,
              resetBy: resetBy,
            );
          } catch (e) {
            logger.e('Failed to send reset notification for $prayerName $timeType: $e');
            // Continue with other notifications even if one fails
          }
        }
      } else {
        // Send notifications for all deleted adjustments (original behavior)
        for (var adjustment in existingAdjustments) {
          final prayerName = adjustment['prayer_name'] as String;
          final timeType = adjustment['time_type'] as String;
          final previousAdjustment = adjustment['adjustment_minutes'] as int;

          try {
            await _sendResetNotification(
              mosqueId: mosqueId,
              mosqueName: mosqueName,
              mosqueLatitude: mosqueLatitude,
              mosqueLongitude: mosqueLongitude,
              prayerName: prayerName,
              timeType: timeType,
              previousAdjustment: previousAdjustment,
              resetBy: resetBy,
            );
          } catch (e) {
            logger.e('Failed to send reset notification for $prayerName $timeType: $e');
            // Continue with other notifications even if one fails
          }
        }
      }

      final notificationCount = onlyNotifyVerified ? (verifiedPrayers?.length ?? 0) : existingAdjustments.length;
      logger.i('Reset completed for mosque: $mosqueName (${existingAdjustments.length} adjustments removed, $notificationCount notifications sent)');

    } catch (e) {
      logger.e('Error resetting mosque adjustments: $e');

      // Log stack trace for debugging
      if (e is Error) {
        logger.e('Stack trace: ${e.stackTrace}');
      }

      rethrow;
    }
  }

  /// Send FCM notification for reset (deletion of adjustment)
  Future<void> _sendResetNotification({
    required String mosqueId,
    required String mosqueName,
    required double mosqueLatitude,
    required double mosqueLongitude,
    required String prayerName,
    required String timeType,
    required int previousAdjustment,
    String? resetBy,
  }) async {
    try {
      logger.d('Sending reset notification for mosque: $mosqueName');
      logger.d('Prayer: $prayerName $timeType, Previous adjustment: ${previousAdjustment}min → RESET TO ORIGINAL');

      // Prepare FCM payload for reset notification
      final fcmPayload = {
        'type': 'mosque_prayer_time_change',
        'mosque_id': mosqueId,
        'mosque_name': mosqueName,
        'mosque_latitude': mosqueLatitude.toString(),
        'mosque_longitude': mosqueLongitude.toString(),
        'prayer_name': prayerName,
        'time_type': timeType,
        'adjustment_minutes': timeType.toLowerCase() == 'iqamah' ? '15' : '0', // Default values: 0 for adhan, 15 for iqamah
        'previous_adjustment': previousAdjustment.toString(),
        'change_source': 'user',
        'effective_date': DateTime.now().toIso8601String().split('T')[0],
        'is_reset': 'true', // Special flag to indicate this is a reset operation
      };

      if (resetBy != null && resetBy.isNotEmpty) {
        fcmPayload['reset_by'] = resetBy;
      }

      logger.d('Reset FCM payload: $fcmPayload');

      final response = await _supabase.functions.invoke(
        'fcm-mosque-notification',
        body: fcmPayload,
      );

      if (response.data != null && response.data['success'] == true) {
        logger.i('Reset notification sent successfully for $prayerName $timeType');
        
        // Log additional details from response if available
        if (response.data['details'] != null) {
          logger.d('Reset notification details: ${response.data['details']}');
        }
      } else {
        logger.w('Reset notification response indicates failure: ${response.data}');
        
        // Log error details if available
        if (response.data != null && response.data['error'] != null) {
          logger.e('Reset notification error: ${response.data['error']}');
        }
      }

    } catch (e) {
      logger.e('Error sending reset notification: $e');
      
      // Log stack trace for debugging
      if (e is Error) {
        logger.e('Stack trace: ${e.stackTrace}');
      }
      
      // Don't rethrow - notification failure shouldn't prevent the reset operation
    }
  }
} 