import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:flutter/foundation.dart';

class FreeQuranService {
  final SupabaseProvider _supabaseProvider;

  FreeQuranService(this._supabaseProvider);

  /// Submit a free Quran request to the database
  Future<void> submitFreeQuranRequest({
    required String fullName,
    required String email,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String country,
    String? preferredLanguage,
    String? reason,
    double? latitude,
    double? longitude,
  }) async {
    try {
      debugPrint('Submitting free Quran request for: $fullName');

      await _supabaseProvider.supabase.from('free_quran_requests').insert({
        'full_name': fullName,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'preferred_language': preferredLanguage,
        'reason': reason,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'requested',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Free Quran request submitted successfully');
    } catch (e) {
      debugPrint('Error submitting free Quran request: $e');
      rethrow;
    }
  }

  /// Get all free Quran requests (admin functionality)
  Future<List<Map<String, dynamic>>> getAllRequests({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabaseProvider.supabase
          .from('free_quran_requests')
          .select();

      if (status != null) {
        query = query.eq('status', status);
      }

      var orderedQuery = query.order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await orderedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching free Quran requests: $e');
      rethrow;
    }
  }

  /// Update the status of a free Quran request (admin functionality)
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? notes,
  }) async {
    try {
      await _supabaseProvider.supabase
          .from('free_quran_requests')
          .update({
            'status': status,
            'admin_notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      debugPrint('Free Quran request status updated to: $status');
    } catch (e) {
      debugPrint('Error updating free Quran request status: $e');
      rethrow;
    }
  }

  /// Get statistics about free Quran requests (admin functionality)
  Future<Map<String, int>> getRequestStatistics() async {
    try {
      final totalResponse = await _supabaseProvider.supabase
          .from('free_quran_requests')
          .select('id')
          .count();

      final requestedResponse = await _supabaseProvider.supabase
          .from('free_quran_requests')
          .select('id')
          .eq('status', 'requested')
          .count();

      final sentResponse = await _supabaseProvider.supabase
          .from('free_quran_requests')
          .select('id')
          .eq('status', 'sent')
          .count();

      final doneResponse = await _supabaseProvider.supabase
          .from('free_quran_requests')
          .select('id')
          .eq('status', 'done')
          .count();

      return {
        'total': totalResponse.count,
        'requested': requestedResponse.count,
        'sent': sentResponse.count,
        'done': doneResponse.count,
      };
    } catch (e) {
      debugPrint('Error fetching free Quran request statistics: $e');
      rethrow;
    }
  }
} 