import 'package:deenhub/features/hadith/domain/services/hadith_content_service.dart';
import 'package:deenhub/features/hadith/domain/services/hadith_search_service.dart';
import 'package:deenhub/main.dart';
import 'package:dart_openai/dart_openai.dart';

import 'package:deenhub/features/ai_chatbot/domain/models/chat_message.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/reference_detector.dart';

import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
import 'package:deenhub/core/services/ai_usage/ai_config_service.dart';

// Define a response class to hold both text and references
class AIResponse {
  final String text;
  final List<IslamicReference> references;

  AIResponse({required this.text, required this.references});
}

class ChatGPTService {
  final HadithSearchService _hadithSearchService = HadithSearchService.instance;
  final HadithContentService _hadithContentService =
      HadithContentService.instance;
  final AIUsageTrackingService _usageTracker = AIUsageTrackingService();
  final AIConfigService _configService = AIConfigService();

  // - Here are some Hadiths from our database:
  // 1. "The merciful are shown mercy by The Merciful." — [Tirmidhi, Book 18, Hadith 1924]
  // 2. "The best of you are those who learn the Quran and teach it." — [Abu Dawood, Book 1, Hadith 146]
  // 3. "The best of you are those who are best to their wives." — [Abu Dawood, Book 1, Hadith 147]
  // 4. "The best of you are those who are best to their neighbors." — [Abu Dawood, Book 1, Hadith 148]
  // 5. "The best of you are those who are best to their family." — [Abu Dawood, Book 1, Hadith 149]
  // 6. "The best of you are those who are best to their community." — [Abu Dawood, Book 1, Hadith 150]

  static String _getSystemPrompt(String hadithRef) =>
      '''
You are DeenGuide, an advanced Islamic AI assistant. Your purpose is to provide authentic, compassionate, and reliable Islamic guidance.

GENERAL BEHAVIOR:
- Be warm, conversational, and concise (3–4 sentences max)
- Speak in first-person
- Use *asterisks* to emphasize Islamic terms (e.g., *salah*, *halal*)
- Use only English (no Arabic script or special characters)
- Use Islamic etiquette such as "peace be upon him", "may Allah guide you"
- Never mock or criticize the user
- Encourage learning, reflection, and kindness

REFERENCE FORMAT:
- Use exact formatting:
  • "Quran [chapter]:[verse]" (e.g., "Quran 2:255" or "Quran 24:35")
  • "[HadithBookName] [ChapterNumber]:[HadithNumber]" (e.g., "Bukhari 22:3964" or "Muslim 11:1158")
  • Ex: When asked about hadiths of riba halal or haram, you should use the following format:
    - "Bukhari 22:3964"
    - "Muslim 11:1158"

WHEN CITING HADITHS:
- Give the hadith reference only if it is needed to answer the question
- Include the exact reference from our database that we include in user question everytime$hadithRef

AUTHORITATIVE SOURCES:
- The Qur'an
- Authentic Hadith from the books listed above
- Sunnah of Prophet Muhammad (peace be upon him)
- The four Sunni madhhabs: Hanafi, Maliki, Shafi'i, Hanbali
- Scholarly consensus (Ijma') and analogy (Qiyas)
- Recognized scholars and councils (IslamQA, Dar al-Ifta, AAOIFI, Mufti Taqi Usmani)

RESPONSE RULES:
1. Always include a Quran or Hadith reference if available
2. If no direct text, explain the view based on a specific madhhab with scholar/text name
3. For fatwa/ijtihad-level questions, say:
   "This requires a personal fatwa. Please consult a qualified scholar or local mufti."

FIQH (ISLAMIC LAW):
- Use legal categories: *fard*, *wajib*, *sunnah*, *mubah*, *makruh*, *haram*
- Respectfully mention differing madhhab views
- Clarify majority/minority opinions
- Include source references when possible

HALAL/HARAM QUESTIONS:
- Always answer with a clear Yes or No
- Justify with Quran or Hadith (e.g., "Quran 2:275")

AQEEDAH (BELIEFS):
- Teach according to Ahlus Sunnah wal Jama'ah
- Use Qur'an, authentic Hadith, and understanding of the Salaf
- Reference classical scholars like Imam al-Tahawi and Ibn Taymiyyah
- Clarify Sunni doctrine without attacking others

SPIRITUAL & MENTAL HEALTH:
- Offer relevant verses, du'as, and advice from the Prophet for struggles like sin, doubt, grief, or anxiety
- Always be empathetic and hopeful
- If user mentions suicidal thoughts, say:
  "Please seek professional help. Islam encourages caring for mental health alongside spiritual healing."

NEW MUSLIM SUPPORT:
- Use simple language and define Arabic terms (e.g., *wudu* = ablution)
- Focus on *tawheed*, prayer, halal living, and sincerity
- Remind: Learning takes time, and intention matters most

DAILY REMINDERS:
- Share:
  • Quran tafsir
  • Short Hadiths and meanings
  • Du'as (Arabic + transliteration + meaning)
  • Quotes from scholars (e.g., Imam Nawawi, Ibn al-Qayyim)
  • Sunnah lifestyle tips
- Always include sources

ISLAMIC FINANCE & MODERN TRANSACTIONS:
- Riba (interest) is *haram* — "Quran 2:275–279"
- Loans: Avoid interest unless in *darurah* (necessity)
- Recommend halal options: Qard Hasan, Murabaha, Ijara, Musharakah
- Investments, Crypto, NFTs:
  • Highlight halal investing rules (no alcohol, gambling, etc.)
  • Mention scholarly differences on crypto, NFTs, stocks
- Disclaimer: 
  "This is general information. For financial decisions, consult a qualified Islamic finance expert."

NON-ISLAMIC QUESTIONS:
- Politely redirect with a specific Islamic alternative
- Example: "Would you like to know about sports activities that Prophet Muhammad encouraged, such as swimming, archery, or horseback riding instead?"

IF YOU DON'T KNOW:
- Say: "This matter is complex or requires ijtihad. Please consult a trusted scholar or fatwa council for specific guidance."

DISCLAIMER INSTRUCTIONS:
- When providing disclaimers or warnings, ALWAYS place them on a new line at the bottom of your response and add "DISCLAIMER: " in the beginning of the disclaimer
- Format disclaimers using *bold text* and make it clear it's a disclaimer
- Examples of when to use disclaimers:
  • When discussing sensitive topics
  • When providing information on Islamic rulings that may have differences of opinion
  • When suggesting users consult scholars for personal matters
- Always make these disclaimers stand out visually by using appropriate formatting
''';

  // Common method for API calls to OpenAI using dart_openai
  Future<AIResponse> _makeApiRequest(List<Map<String, String>> messages) async {
    try {
      // Get AI config for API key and model
      final config = await _configService.getCurrentConfig();
      if (config.apiKey.isEmpty || config.apiKey == '') {
        return AIResponse(
          text: 'AI service is currently unavailable. Please try again later.',
          references: [],
        );
      }

      // Check token limit before making the request
      final canMakeRequest = await _usageTracker.canMakeRequest(
        estimatedTokens: config.maxCompletionTokens,
        monthlyTokenLimit: config.monthlyTokenLimit,
      );

      if (!canMakeRequest) {
        return AIResponse(
          text:
              'You have exceeded your monthly token limit. Please upgrade your plan or wait until next month.',
          references: [],
        );
      }

      // Initialize OpenAI client with API key
      OpenAI.apiKey = config.apiKey;

      // Convert messages to OpenAI message format
      final openaiMessages = messages.map((msg) {
        return OpenAIChatCompletionChoiceMessageModel(
          role: msg['role'] == 'system'
              ? OpenAIChatMessageRole.system
              : msg['role'] == 'user'
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              msg['content'] ?? '',
            ),
          ],
        );
      }).toList();

      // Make the chat completion request
      final chatCompletion = await OpenAI.instance.chat.create(
        model: config.modelName,
        messages: openaiMessages,
        temperature: 1,
        maxTokens: config.maxCompletionTokens,
      );

      logger.i('Response received from OpenAI | ${config.modelName} | ${config.maxCompletionTokens}');

      // Extract the response content
      if (chatCompletion.choices.isEmpty ||
          chatCompletion.choices[0].message.content == null ||
          chatCompletion.choices[0].message.content!.isEmpty) {
        logger.e('Empty response content from OpenAI');
        return AIResponse(
          text:
              'Sorry, I couldn\'t generate a response. Please try asking in a different way.',
          references: [],
        );
      }

      String aiResponse = '';
      for (final content in chatCompletion.choices[0].message.content!) {
        if (content.type == 'text') {
          aiResponse += content.text ?? '';
        }
      }

      if (aiResponse.trim().isEmpty) {
        logger.e('Empty response content from OpenAI after processing');
        return AIResponse(
          text:
              'Sorry, I couldn\'t generate a response. Please try asking in a different way.',
          references: [],
        );
      }

      // Track AI usage with actual token data from OpenAI response
      try {
        final usage = chatCompletion.usage;
        final totalTokens = usage.totalTokens;
        await _usageTracker.trackUsage(
          tokensUsed: totalTokens,
          monthlyTokenLimit: config.monthlyTokenLimit,
        );

        logger.i('Tracked AI usage: $totalTokens tokens');
      } catch (trackingError) {
        logger.e('Error tracking AI usage: $trackingError');
      }

      logger.i('Raw AI response: $aiResponse');

      // Process references and get detected references
      final processResult = await ReferenceDetector.processReferences(
        aiResponse,
      );

      logger.i('Processed references: ${processResult.text}');

      // Create new AIResponse with markdown-style formatting for bold text
      String formattedText = processResult.text.replaceAll('*', '**');
      return AIResponse(
        text: formattedText,
        references: processResult.references,
      );
    } catch (e) {
      logger.e('Error during OpenAI API request: $e');

      // Handle different types of OpenAI exceptions
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('authentication') ||
          errorMessage.contains('401') ||
          errorMessage.contains('unauthorized')) {
        return AIResponse(
          text: 'Authentication error. Please check your API key.',
          references: [],
        );
      } else if (errorMessage.contains('rate limit') ||
          errorMessage.contains('429') ||
          errorMessage.contains('too many requests')) {
        return AIResponse(
          text: 'Rate limit exceeded. Please wait a moment and try again.',
          references: [],
        );
      } else {
        return AIResponse(
          text:
              'An error occurred while getting a response. Please try again later.',
          references: [],
        );
      }
    }
  }

  // TODO: DON'T USE THIS FUNCTION FOR NOW BUT DON'T DELETE IT
  /// Fetches relevant hadiths using vector search and formats them for the prompt
  Future<String> _getRelevantHadithsForPrompt(String query) async {
    try {
      // Search for relevant hadiths using vector embeddings
      final searchResult = await _hadithSearchService.searchWithEmbeddings(
        query,
        limit: 2,
      );

      // If no results, return empty string
      if (searchResult.hadiths.isEmpty) {
        return '';
      }

      // Format the hadiths for inclusion in the prompt
      StringBuffer hadithsText = StringBuffer();
      hadithsText.writeln('\nHere are some Hadiths from our database:');

      for (int i = 0; i < searchResult.hadiths.length; i++) {
        final hadith = searchResult.hadiths[i];
        final bookName = _hadithContentService.getBookName(hadith.bookId);
        hadithsText.writeln(
          '${i + 1}. "${hadith.fullText}" — [$bookName ${hadith.chapterId}:${hadith.idInBook}]',
        );
      }

      hadithsText.writeln(
        '\nPlease use these hadiths if relevant to the question, otherwise you can ignore them.',
      );

      logger.i(
        'Added ${searchResult.hadiths.length} relevant hadiths to prompt',
      );
      return hadithsText.toString();
    } catch (e) {
      logger.e('Error getting relevant hadiths: $e');
      return '';
    }
  }

  // Token-efficient conversational method
  Future<AIResponse> getResponseWithContext(
    String userMessage,
    List<ChatMessage> recentMessages,
  ) async {
    try {
      if (recentMessages.isNotEmpty) recentMessages.removeAt(0);
      logger.i("Last messages:\n${recentMessages.lastOrNull?.message}");
      // final relevantHadiths = await _getRelevantHadithsForPrompt(userMessage);

      // Create message history in OpenAI's expected format
      final List<Map<String, String>> messageHistory = [
        {'role': 'system', 'content': _getSystemPrompt('')},
        // {'role': 'system', 'content': _getSystemPrompt(relevantHadiths)}
      ];

      // Only use last 2-3 messages for context (token efficient)
      final historyToSend = recentMessages.length > 3
          ? recentMessages.sublist(recentMessages.length - 3)
          : recentMessages;

      for (var message in historyToSend) {
        messageHistory.add({
          'role': message.isUser ? 'user' : 'assistant',
          'content': _truncateIfNeeded(message.message),
        });
      }

      return await _makeApiRequest(messageHistory);
    } catch (e) {
      return AIResponse(
        text: 'Error processing request: ${e.toString()}',
        references: [],
      );
    }
  }

  String _truncateIfNeeded(String text) {
    return text.length > 400 ? "${text.substring(0, 400)}..." : text;
  }

  // Keep original method for backward compatibility
  Future<AIResponse> getResponse(String userMessage) async {
    try {
      final messages = [
        {'role': 'system', 'content': _getSystemPrompt('')},
        {'role': 'user', 'content': userMessage},
      ];

      return await _makeApiRequest(messages);
    } catch (e) {
      return AIResponse(
        text: 'Error processing request: ${e.toString()}',
        references: [],
      );
    }
  }
}
