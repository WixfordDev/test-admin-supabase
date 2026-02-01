import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deenhub/main.dart';

class EmbeddingsService {
  // Singleton instance
  static final EmbeddingsService _instance = EmbeddingsService._internal();
  static EmbeddingsService get instance => _instance;
  factory EmbeddingsService() => _instance;
  EmbeddingsService._internal();

  // OpenAI API settings
  static const String _baseUrl = 'https://api.openai.com/v1/embeddings';
  static const String _model = 'text-embedding-3-small';
  static const int _expectedDimensions = 512;
  final String _apiKey = "";

  /// Generate embeddings for the given text input
  /// Returns a list of doubles representing the embedding vector
  Future<List<double>> generateEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'input': text,
          'dimensions': _expectedDimensions,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> embedding = data['data'][0]['embedding'];
        return embedding.map<double>((e) => e.toDouble()).toList();
      } else {
        logger.e('Error generating embeddings: ${response.statusCode} ${response.body}');
        throw Exception('Failed to generate embeddings: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Exception while generating embeddings: $e');
      throw Exception('Failed to generate embeddings: $e');
    }
  }
}
