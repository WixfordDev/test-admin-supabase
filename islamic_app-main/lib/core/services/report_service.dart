import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/main.dart';

enum ReportType {
  aiChatbot('ai_chatbot'),
  aiExplanation('ai_explanation'),
  hadith('hadith');

  const ReportType(this.value);
  final String value;
}

enum ReportCategory {
  incorrectInformation('incorrect_information', 'Incorrect Information'),
  inappropriateContent('inappropriate_content', 'Inappropriate Content'),
  misleadingGuidance('misleading_guidance', 'Misleading Guidance'),
  technicalError('technical_error', 'Technical Error'),
  inconsistency('inconsistency', 'Inconsistency'),
  offensiveContent('offensive_content', 'Offensive Content'),
  other('other', 'Other');

  const ReportCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum ReportStatus {
  pending('pending'),
  reviewing('reviewing'),
  resolved('resolved'),
  dismissed('dismissed');

  const ReportStatus(this.value);
  final String value;
}

class ReportData {
  final String id;
  final String userId;
  final ReportType type;
  final ReportCategory category;
  final String title;
  final String? description;
  final String? contentId;
  final Map<String, dynamic>? contentData;
  final Map<String, dynamic>? contextData;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportData({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.title,
    this.description,
    this.contentId,
    this.contentData,
    this.contextData,
    required this.status,
    this.adminNotes,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: ReportType.values.firstWhere((e) => e.value == json['report_type']),
      category: ReportCategory.values.firstWhere((e) => e.value == json['category']),
      title: json['title'] as String,
      description: json['description'] as String?,
      contentId: json['content_id'] as String?,
      contentData: json['content_data'] as Map<String, dynamic>?,
      contextData: json['context_data'] as Map<String, dynamic>?,
      status: ReportStatus.values.firstWhere((e) => e.value == json['status']),
      adminNotes: json['admin_notes'] as String?,
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      resolvedBy: json['resolved_by'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_type': type.value,
      'category': category.value,
      'title': title,
      'description': description,
      'content_id': contentId,
      'content_data': contentData,
      'context_data': contextData,
      'status': status.value,
      'admin_notes': adminNotes,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreateReportRequest {
  final ReportType type;
  final ReportCategory category;
  final String title;
  final String? description;
  final String? contentId;
  final Map<String, dynamic>? contentData;
  final Map<String, dynamic>? contextData;

  const CreateReportRequest({
    required this.type,
    required this.category,
    required this.title,
    this.description,
    this.contentId,
    this.contentData,
    this.contextData,
  });

  Map<String, dynamic> toJson() {
    return {
      'report_type': type.value,
      'category': category.value,
      'title': title,
      'description': description,
      'content_id': contentId,
      'content_data': contentData,
      'context_data': contextData,
      'status': ReportStatus.pending.value,
    };
  }

  // Static factory methods for different report types
  static CreateReportRequest aiChatbot({
    required ReportCategory category,
    required String title,
    String? description,
    required String messageContent,
    required int messageIndex,
    Map<String, dynamic>? additionalContext,
  }) {
    return CreateReportRequest(
      type: ReportType.aiChatbot,
      category: category,
      title: title,
      description: description,
      contentId: 'message_$messageIndex',
      contentData: {
        'message_content': messageContent,
        'message_index': messageIndex,
      },
      contextData: additionalContext,
    );
  }

  static CreateReportRequest aiExplanation({
    required ReportCategory category,
    required String title,
    String? description,
    required String explanation,
    required int surahNumber,
    required int verseNumber,
    Map<String, dynamic>? additionalContext,
  }) {
    return CreateReportRequest(
      type: ReportType.aiExplanation,
      category: category,
      title: title,
      description: description,
      contentId: 'explanation_${surahNumber}_$verseNumber',
      contentData: {
        'explanation_text': explanation,
        'surah_number': surahNumber,
        'verse_number': verseNumber,
      },
      contextData: additionalContext,
    );
  }

  static CreateReportRequest hadith({
    required ReportCategory category,
    required String title,
    String? description,
    required String hadithId,
    required String bookId,
    Map<String, dynamic>? additionalContext,
  }) {
    return CreateReportRequest(
      type: ReportType.hadith,
      category: category,
      title: title,
      description: description,
      contentId: 'hadith_${bookId}_$hadithId',
      contentData: {
        'hadith_id': hadithId,
        'book_id': bookId,
      },
      contextData: additionalContext,
    );
  }
}

class ReportService {
  static final ReportService _instance = ReportService._internal();
  static ReportService get instance => _instance;
  ReportService._internal();

  SupabaseProvider? _supabaseProvider;

  void initialize() {
    try {
      _supabaseProvider = getIt<SupabaseProvider>();
      logger.i('ReportService initialized successfully');
    } catch (e) {
      logger.e('Failed to initialize ReportService: $e');
    }
  }

  SupabaseProvider get _provider {
    if (_supabaseProvider == null) {
      initialize();
    }
    if (_supabaseProvider == null) {
      throw Exception('ReportService not properly initialized. Supabase provider is null.');
    }
    return _supabaseProvider!;
  }

  /// Submit a new report
  Future<String> submitReport(CreateReportRequest request) async {
    try {
      final user = _provider.supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to submit reports');
      }

      final reportData = {
        ...request.toJson(),
        'user_id': user.id,
      };

      final response = await _provider.supabase
          .from('reports')
          .insert(reportData)
          .select('id')
          .single();

      logger.i('Report submitted successfully: ${response['id']}');
      return response['id'] as String;
    } catch (e) {
      logger.e('Error submitting report: $e');
      rethrow;
    }
  }

  /// Get user's submitted reports
  Future<List<ReportData>> getUserReports({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _provider.supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to view reports');
      }

      final response = await _provider.supabase
          .from('reports')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => ReportData.fromJson(json))
          .toList();
    } catch (e) {
      logger.e('Error fetching user reports: $e');
      rethrow;
    }
  }

  /// Get a specific report by ID
  Future<ReportData?> getReport(String reportId) async {
    try {
      final user = _provider.supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to view reports');
      }

      final response = await _provider.supabase
          .from('reports')
          .select('*')
          .eq('id', reportId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return ReportData.fromJson(response);
    } catch (e) {
      logger.e('Error fetching report: $e');
      rethrow;
    }
  }

  /// Check if user can submit reports (rate limiting could be added here)
  Future<bool> canSubmitReport() async {
    try {
      final user = _provider.supabase.auth.currentUser;
      if (user == null) return false;

      // Check if user has submitted too many reports recently (optional rate limiting)
      final recentReports = await _provider.supabase
          .from('reports')
          .select('id')
          .eq('user_id', user.id)
          .gte('created_at', DateTime.now().subtract(const Duration(hours: 1)).toIso8601String());

      // Allow up to 5 reports per hour
      final count = (recentReports as List).length;
      return count < 5;
    } catch (e) {
      logger.e('Error checking report submission eligibility: $e');
      return false;
    }
  }

  /// Refresh reports (useful for pull-to-refresh)
  Future<void> refreshReports() async {
    // This method can be used to invalidate any cached reports
    // For now, it's just a placeholder
    logger.i('Reports refreshed');
  }
} 