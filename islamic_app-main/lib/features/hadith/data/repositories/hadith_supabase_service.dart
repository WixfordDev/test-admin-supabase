import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/features/hadith/domain/models/hadith.dart';
import 'package:deenhub/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HadithSupabaseService {
  static final HadithSupabaseService _instance = HadithSupabaseService._internal();
  static HadithSupabaseService get instance => _instance;
  factory HadithSupabaseService() => _instance;
  HadithSupabaseService._internal();

  late final SupabaseClient _supabase = getIt.get<SupabaseProvider>().supabase;

  /// Search hadiths using the Supabase database function
  Future<List<Hadith>> searchHadiths({
    String? query,
    int? bookId,
    int? chapterId,
    int? hadithNumber,
    bool isAdvanced = true,
  }) async {
    try {
      final response = await _supabase.rpc(
        isAdvanced ? 'search_hadiths_advanced' : 'match_hadiths',
        params: {
          'q': query,
          'b_id': bookId,
          'c_id': chapterId,
          'h_number': hadithNumber,
        },
      );
      logger.i('Search hadiths response: $response | $query | $bookId');

      final data = response as List;
      return data.map((json) => Hadith.fromJsonSupabase(json)).toList();
    } catch (e) {
      logger.e('Error searching hadiths: $e');
      rethrow;
    }
  }

  /// Search hadiths using vector embeddings for semantic similarity
  Future<List<Hadith>> searchHadithsWithEmbeddings({
    required List<double> queryEmbedding,
    int limit = 3,
    double matchThreshold = 0.5,
  }) async {
    try {
      final response = await _supabase.rpc(
        'match_hadiths',
        params: {
          'query_embedding': queryEmbedding,
          'match_threshold': matchThreshold,
          'match_count': limit,
        },
      );
      logger.i('Vector search hadiths response: ${response.length} results');

      final data = response as List;
      return data.map((json) => Hadith.fromJsonSupabase(json)).toList();
    } catch (e) {
      logger.e('Error searching hadiths with embeddings: $e');
      rethrow;
    }
  }
}
