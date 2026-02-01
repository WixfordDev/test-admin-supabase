import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/nearby_mosques/data/models/mosque_adjustment.dart';
import 'package:deenhub/features/nearby_mosques/data/models/mosque_facility.dart';
import 'package:flutter/foundation.dart';

/// A service that handles interaction with Supabase for mosque data
class SupabaseMosqueService {
  final SupabaseProvider _supabaseProvider;
  
  SupabaseMosqueService(this._supabaseProvider);
  
  /// Save mosque time adjustments to Supabase with notification support
  Future<void> saveMosqueAdjustment(
    MosqueAdjustment adjustment, {
    String changeSource = 'user',  // 'user' or 'prediction'
    DateTime? effectiveDate,
    String? changedBy,
    String? notes,
  }) async {
    final dbMap = adjustment.toDbMap();
    
    // Add the new tracking fields
    dbMap['change_source'] = changeSource;
    dbMap['effective_date'] = (effectiveDate ?? DateTime.now()).toIso8601String().split('T')[0]; // Date only
    if (changedBy != null) {
      dbMap['changed_by'] = changedBy;
    }
    if (notes != null) {
      dbMap['notes'] = notes;
    }
    
    try {
      // Use upsert with proper conflict resolution
      await _supabaseProvider.supabase
          .from('mosque_adjustments')
          .upsert(
            dbMap,
            onConflict: 'mosque_id,prayer_name,time_type',
            ignoreDuplicates: false,
          );
      
      debugPrint('Mosque adjustment saved successfully with change source: $changeSource');
    } catch (e) {
      debugPrint('Error saving mosque adjustment: $e');
      
      // If upsert fails, try manual update approach
      try {
        debugPrint('Attempting manual update approach...');
        
        // First try to update existing record
        final updateResponse = await _supabaseProvider.supabase
            .from('mosque_adjustments')
            .update({
              'adjustment_minutes': dbMap['adjustment_minutes'],
              'change_source': dbMap['change_source'],
              'effective_date': dbMap['effective_date'],
              'changed_by': dbMap['changed_by'],
              'notes': dbMap['notes'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('mosque_id', dbMap['mosque_id'])
            .eq('prayer_name', dbMap['prayer_name'])
            .eq('time_type', dbMap['time_type'])
            .select();
        
        // If no rows were updated, insert new record
        if (updateResponse.isEmpty) {
          await _supabaseProvider.supabase
              .from('mosque_adjustments')
              .insert(dbMap);
        }
        
        debugPrint('Mosque adjustment saved successfully using manual approach');
      } catch (fallbackError) {
        debugPrint('Fallback save method also failed: $fallbackError');
        rethrow;
      }
    }
  }

  /// Save a user adjustment (for immediate notifications)
  Future<void> saveUserAdjustment(
    MosqueAdjustment adjustment, {
    String? changedBy,
    String? notes,
  }) async {
    await saveMosqueAdjustment(
      adjustment,
      changeSource: 'user',
      effectiveDate: DateTime.now(),
      changedBy: changedBy,
      notes: notes,
    );
  }

  /// Save a prediction adjustment (for threshold-based notifications)
  Future<void> savePredictionAdjustment(
    MosqueAdjustment adjustment, {
    DateTime? effectiveDate,
    String? notes,
  }) async {
    await saveMosqueAdjustment(
      adjustment,
      changeSource: 'prediction',
      effectiveDate: effectiveDate ?? DateTime.now().add(const Duration(days: 1)),
      changedBy: 'system',
      notes: notes,
    );
  }
  
  /// Get all adjustments for a specific mosque
  Future<List<MosqueAdjustment>> getMosqueAdjustments(String mosqueId) async {
    try {
      final response = await _supabaseProvider.supabase
          .from('mosque_adjustments')
          .select()
          .eq('mosque_id', mosqueId);
          
      return (response as List)
          .map((json) => MosqueAdjustment.fromDbMap(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching mosque adjustments: $e');
      return [];
    }
  }
  
  /// Save mosque metadata to Supabase
  Future<void> saveMosqueMetadata({
    required String mosqueId,
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? phone,
    String? website,
    String? additionalInfo,
  }) async {
    final metadataMap = {
      'mosque_id': mosqueId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'website': website,
      'additional_info': additionalInfo,
    };

    try {
      await _supabaseProvider.supabase
          .from('mosques_metadata')
          .upsert(
            metadataMap,
            onConflict: 'mosque_id',
            ignoreDuplicates: false,
          );
      
      debugPrint('Mosque metadata saved successfully');
    } catch (e) {
      debugPrint('Error saving mosque metadata: $e');
      
      // If upsert fails, try manual update approach
      try {
        debugPrint('Attempting manual update approach for metadata...');
        
        // First try to update existing record
        final updateResponse = await _supabaseProvider.supabase
            .from('mosques_metadata')
            .update({
              'name': name,
              'latitude': latitude,
              'longitude': longitude,
              'address': address,
              'phone': phone,
              'website': website,
              'additional_info': additionalInfo,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('mosque_id', mosqueId)
            .select();
        
        // If no rows were updated, insert new record
        if (updateResponse.isEmpty) {
          await _supabaseProvider.supabase
              .from('mosques_metadata')
              .insert(metadataMap);
        }
        
        debugPrint('Mosque metadata saved successfully using manual approach');
      } catch (fallbackError) {
        debugPrint('Fallback metadata save method also failed: $fallbackError');
        rethrow;
      }
    }
  }
  
  /// Get time changes for mosques (for notification checking)
  Future<List<Map<String, dynamic>>> getMosqueTimeChangesSince(DateTime? since) async {
    try {
      final response = await _supabaseProvider.supabase
          .rpc('get_mosque_time_changes_since', params: {
            'since_timestamp': since?.toIso8601String(),
          });
          
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching mosque time changes: $e');
      return [];
    }
  }
  
  /// Get recent significant time changes (for general monitoring)
  Future<List<Map<String, dynamic>>> getRecentSignificantTimeChanges({int hoursBack = 24}) async {
    try {
      final response = await _supabaseProvider.supabase
          .rpc('get_recent_significant_time_changes', params: {
            'hours_back': hoursBack,
          });
          
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error fetching recent significant time changes: $e');
      return [];
    }
  }

  /// Test the notification system by creating a test adjustment
  Future<void> testNotificationSystem(String mosqueId) async {
    try {
      // Create a test adjustment to trigger notification
      final testAdjustment = MosqueAdjustment(
        mosqueId: mosqueId,
        prayerName: 'fajr',
        timeType: 'iqamah',
        adjustmentMinutes: 15,
        updatedAt: DateTime.now(),
      );
      
      await saveUserAdjustment(
        testAdjustment,
        changedBy: 'test_user',
        notes: 'Testing notification system',
      );
      
      debugPrint('Test notification triggered for mosque: $mosqueId');
    } catch (e) {
      debugPrint('Error testing notification system: $e');
      rethrow;
    }
  }

  // ============================================================================
  // MOSQUE FACILITIES METHODS
  // ============================================================================

  /// Save mosque facility information to Supabase
  Future<void> saveMosqueFacility(
    MosqueFacility facility, {
    String? updatedBy,
  }) async {
    final facilityMap = facility.toDbMap();
    
    // Add or update the updatedBy field
    if (updatedBy != null) {
      facilityMap['updated_by'] = updatedBy;
    }
    
    // Always set last_updated to current time
    facilityMap['last_updated'] = DateTime.now().toIso8601String();

    try {
      // Use upsert with proper conflict resolution
      await _supabaseProvider.supabase
          .from('mosque_facilities')
          .upsert(
            facilityMap,
            onConflict: 'mosque_id,facility_type',
            ignoreDuplicates: false,
          );
      
      debugPrint('Mosque facility saved successfully: ${facility.facilityType.displayName} for mosque ${facility.mosqueId}');
    } catch (e) {
      debugPrint('Error saving mosque facility: $e');
      
      // If upsert fails, try manual update approach
      try {
        debugPrint('Attempting manual update approach for facility...');
        
        // First try to update existing record
        final updateResponse = await _supabaseProvider.supabase
            .from('mosque_facilities')
            .update({
              'availability': facilityMap['availability'],
              'description': facilityMap['description'],
              'additional_info': facilityMap['additional_info'],
              'last_updated': facilityMap['last_updated'],
              'updated_by': facilityMap['updated_by'],
            })
            .eq('mosque_id', facilityMap['mosque_id'])
            .eq('facility_type', facilityMap['facility_type'])
            .select();
        
        // If no rows were updated, insert new record
        if (updateResponse.isEmpty) {
          await _supabaseProvider.supabase
              .from('mosque_facilities')
              .insert(facilityMap);
        }
        
        debugPrint('Mosque facility saved successfully using manual approach');
      } catch (fallbackError) {
        debugPrint('Fallback facility save method also failed: $fallbackError');
        rethrow;
      }
    }
  }
  
  /// Get all facilities for a specific mosque
  Future<List<MosqueFacility>> getMosqueFacilities(String mosqueId) async {
    try {
      final response = await _supabaseProvider.supabase
          .from('mosque_facilities')
          .select()
          .eq('mosque_id', mosqueId);
          
      return (response as List)
          .map((json) => MosqueFacility.fromDbMap(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching mosque facilities: $e');
      return [];
    }
  }

  /// Save multiple facilities for a mosque at once
  Future<void> saveMosqueFacilities(
    List<MosqueFacility> facilities, {
    String? updatedBy,
  }) async {
    try {
      for (final facility in facilities) {
        await saveMosqueFacility(facility, updatedBy: updatedBy);
      }
      debugPrint('All mosque facilities saved successfully');
    } catch (e) {
      debugPrint('Error saving mosque facilities: $e');
      rethrow;
    }
  }

  /// Delete a specific facility for a mosque
  Future<void> deleteMosqueFacility(
    String mosqueId,
    FacilityType facilityType,
  ) async {
    try {
      await _supabaseProvider.supabase
          .from('mosque_facilities')
          .delete()
          .eq('mosque_id', mosqueId)
          .eq('facility_type', facilityType.name);
      
      debugPrint('Mosque facility deleted successfully: ${facilityType.displayName} for mosque $mosqueId');
    } catch (e) {
      debugPrint('Error deleting mosque facility: $e');
      rethrow;
    }
  }

  /// Get facilities by category (General, For Women, Accessibility)
  Future<Map<String, List<MosqueFacility>>> getMosqueFacilitiesByCategory(String mosqueId) async {
    try {
      final allFacilities = await getMosqueFacilities(mosqueId);
      
      final Map<String, List<MosqueFacility>> categorizedFacilities = {
        'General': [],
        'For Women': [],
        'Accessibility': [],
      };
      
      for (final facility in allFacilities) {
        final category = facility.facilityType.category;
        if (categorizedFacilities.containsKey(category)) {
          categorizedFacilities[category]!.add(facility);
        }
      }
      
      return categorizedFacilities;
    } catch (e) {
      debugPrint('Error fetching categorized mosque facilities: $e');
      return {
        'General': [],
        'For Women': [],
        'Accessibility': [],
      };
    }
  }
} 