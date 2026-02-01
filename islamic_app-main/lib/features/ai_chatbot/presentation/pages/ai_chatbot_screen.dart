import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/reference_detector.dart';
import 'package:deenhub/features/ai_chatbot/presentation/components/ai_chatbot_about_dialog.dart';
import 'package:deenhub/features/ai_chatbot/presentation/components/chat_message_widgets.dart';
import 'package:deenhub/features/ai_chatbot/presentation/components/typing_indicator.dart';
import 'package:deenhub/features/ai_chatbot/presentation/components/welcome_banner.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/chat_message.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/chatgpt_service.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/verse_view_screen.dart';
import 'package:deenhub/core/services/database/chat_history_service.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/core/widgets/dialog/report_dialog.dart';
import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
import 'dart:async';

class AIChatbotScreen extends StatefulWidget {
  final int? sessionId;

  const AIChatbotScreen({this.sessionId, super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen>
    with TickerProviderStateMixin {
  // Replace SharedPrefs with ChatHistoryService
  final ChatHistoryService _chatHistoryService = getIt<ChatHistoryService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatGPTService _chatGPTService = ChatGPTService();
  bool _isTyping = false;
  bool _isSubscribed = false;
  bool _isLoading = true;
  int? _currentSessionId;
  // Listen to subscription updates
  StreamSubscription<bool>? _subscriptionStatusSub;

  // Animation controllers for typing indicator
  late AnimationController _animationController1;
  late AnimationController _animationController2;
  late AnimationController _animationController3;

  // Animations for each dot
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  // Suggested questions for quick access
  final List<String> _suggestedQuestions = [
    "How to perform wudu?",
    "What are the five pillars of Islam?",
    "How to calculate Zakat?",
    "Dua for seeking knowledge",
  ];

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _initializeChatSession();

    // Initialize animation controllers with different durations for more natural effect
    _animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _animationController2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _animationController3 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    // Create animations with custom curves
    _animation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController1, curve: Curves.easeInOut),
    );

    _animation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController2, curve: Curves.easeInOut),
    );

    _animation3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController3, curve: Curves.easeInOut),
    );

    // Listen for subscription purchase updates and refresh access instantly
    _subscriptionStatusSub =
        getIt<SubscriptionService>().purchaseStatusStream.listen((success) async {
      final isPro = await SubscriptionService.isDeenHubProSubscribed();
      if (!mounted) return;
      setState(() {
        _isSubscribed = isPro;
      });
    });
  }

  // Initialize chat session based on provided session ID or most recent session
  Future<void> _initializeChatSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.sessionId != null) {
        // Load specific session if ID was provided
        await _loadChatSession(widget.sessionId!);
      } else {
        // Try to load most recent session
        final mostRecentSession =
            await _chatHistoryService.getMostRecentSession();

        if (mostRecentSession != null) {
          await _loadChatSession(mostRecentSession.id);
        } else {
          // No existing sessions, create a new one with initial message
          _addInitialBotMessage();
        }
      }
    } catch (e) {
      logger.e('Error initializing chat session: $e');
      _addInitialBotMessage();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load messages from a specific chat session
  Future<void> _loadChatSession(int sessionId) async {
    try {
      final messages = await _chatHistoryService.getSessionMessages(sessionId);

      setState(() {
        _currentSessionId = sessionId;
        _messages.clear();
        _messages.addAll(messages);
      });

      // Scroll to bottom after loading chat history
      _scrollToBottom();
    } catch (e) {
      logger.e('Error loading chat session $sessionId: $e');
      // If error loading session, add initial message
      _addInitialBotMessage();
    }
  }

  // Add initial bot welcome message and create new session
  Future<void> _addInitialBotMessage() async {
    logger.i('Adding initial bot message');
    if (_messages.isNotEmpty) return; // Don't add if we already have messages

    final welcomeMessage = ChatMessage(
      message:
          "Assalamu Alaikum! I'm DeenGuide, your Islamic assistant on DeenHub. How can I assist you today?",
      type: MessageType.bot,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });

    // Create new session with this welcome message
    try {
      final sessionId = await _chatHistoryService.createChatSession(
        title: "New Chat",
        initialMessage: welcomeMessage,
      );

      setState(() {
        _currentSessionId = sessionId;
      });
    } catch (e) {
      logger.e('Error saving initial message: $e');
    }
  }

  // Create a new chat session
  Future<void> _createNewChatSession() async {
    setState(() {
      _messages.clear();
      _currentSessionId = null;
    });

    await _addInitialBotMessage();
  }

  void _sendMessage({String? predefinedMessage}) async {
    // Check authentication status first
    try {
      final authBloc = getIt<AuthBloc>();
      final isLoggedIn = authBloc.state.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      if (!isLoggedIn) {
        _showLoginRequiredDialog();
        return;
      }
    } catch (e) {
      // If there's an error getting auth status, show login dialog
      logger.e('Error checking authentication status: $e');
      _showLoginRequiredDialog();
      return;
    }

    // Check subscription before sending message
    if (!_isSubscribed) {
      _showSubscriptionDialog();
      return;
    }

    // Check monthly token limit before sending message
    final usageTracker = AIUsageTrackingService();
    final canMakeRequest = await usageTracker.canMakeRequest(
      estimatedTokens: 500, // Estimate for a typical request
    );

    logger.d('canMakeRequest: $canMakeRequest');

    if (!canMakeRequest) {
      _showMonthlyLimitExceededDialog();
      return;
    }

    // Use either predefined message or the text input
    final userMessage = predefinedMessage ?? _messageController.text.trim();
    if (userMessage.isEmpty) return;

    _messageController.clear();

    // Create user message
    final message = ChatMessage(
      message: userMessage,
      type: MessageType.user,
    );

    setState(() {
      _messages.add(message);
      _isTyping = true;
    });

    // Save message to database
    if (_currentSessionId != null) {
      try {
        await _chatHistoryService.addMessageToSession(
            _currentSessionId!, message);
      } catch (e) {
        logger.e('Error saving user message: $e');
      }
    }

    _startTypingAnimation(); // Start typing animation
    _scrollToBottom(); // Scroll to bottom
    await _getBotResponse(userMessage); // Process message and get response
  }

  Future<void> _getBotResponse(String userMessage) async {
    try {
      // Get response using the token-efficient context method
      final aiResponse =
          await _chatGPTService.getResponseWithContext(userMessage, _messages);

      // Create bot message with provided references
      final message = ChatMessage(
        message: aiResponse.text,
        type: MessageType.bot,
        references: aiResponse.references,
      );

      if (mounted) {
        setState(() {
          _messages.add(message);
          _isTyping = false;
        });
      }

      // Save bot message to database
      if (_currentSessionId != null) {
        try {
          await _chatHistoryService.addMessageToSession(
              _currentSessionId!, message);

          // Update session title with first user message if this is the first message exchange
          if (_messages.length == 3 && _messages[1].isUser) {
            final userFirstMessage = _messages[1].message;
            final title = userFirstMessage.length > 30
                ? '${userFirstMessage.substring(0, 27)}...'
                : userFirstMessage;

            await _chatHistoryService.updateSessionTitle(
                _currentSessionId!, title);
          }
        } catch (e) {
          logger.e('Error saving bot response: $e');
        }
      }

      // Stop typing animation
      _stopTypingAnimation();

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      final errorMessage = ChatMessage(
        message:
            "Sorry, I encountered an error while processing your request. Please try again later.",
        type: MessageType.bot,
        references: [], // No references for error message
      );

      if (mounted) {
        setState(() {
          _messages.add(errorMessage);
          _isTyping = false;
        });
      }

      // Save error message to database
      if (_currentSessionId != null) {
        try {
          await _chatHistoryService.addMessageToSession(
              _currentSessionId!, errorMessage);
        } catch (e) {
          logger.e('Error saving error message: $e');
        }
      }

      // Stop typing animation
      _stopTypingAnimation();

      // Scroll to bottom
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    // Dispose animation controllers
    _animationController1.dispose();
    _animationController2.dispose();
    _animationController3.dispose();

    // Cancel subscription listener
    _subscriptionStatusSub?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: CircularProgressIndicator().center());
    }

    return AppBarScaffold(
      pageTitle: 'DeenGuide',
      searchBar: Row(
        children: [
          Icon(Icons.bubble_chart, color: Colors.white),
          gapW4,
          Text(
            "DeenGuide",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      appBarActions: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: _createNewChatSession,
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.history_outlined, color: Colors.white),
          onPressed: () => context.pushNamed(Routes.chatHistory.name),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => const AiChatbotAboutDialog(),
          ),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(Assets.imagesSubtlePattern),
            opacity: .2,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          children: [
            const WelcomeBanner(),
            _buildChatMessages().expanded(),
            _buildSuggestedQuestions(),
            MessageInputField(
                context: context,
                messageController: _messageController,
                isTyping: _isTyping,
                onSend: _sendMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    // Capture the current state to avoid race conditions
    final messages = List<ChatMessage>.from(_messages);
    final isCurrentlyTyping = _isTyping;

    return ListView.builder(
      controller: _scrollController,
      padding: p16,
      itemCount: messages.length + (isCurrentlyTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // If we're at the last item and typing, show the typing indicator
        if (index == messages.length && isCurrentlyTyping) {
          return TypingIndicator(
            animation1: _animation1,
            animation2: _animation2,
            animation3: _animation3,
          );
        }

        // Safety check: ensure index is within bounds
        if (index >= messages.length) {
          return const SizedBox.shrink(); // Return empty widget if index is out of bounds
        }

        // Otherwise, show the message
        final message = messages[index];
        return ChatMessageItem(
            context: context,
            message: message,
            index: index,
            onReferenceTap: _navigateToReference,
            onReportTap: _showReportDialog);
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    if (_messages.length > 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Suggested Questions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2A7A8C),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((question) {
              return InkWell(
                onTap: () => _sendMessage(predefinedMessage: question),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A7A8C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2A7A8C).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2A7A8C),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Method to navigate to references
  void _navigateToReference(IslamicReference reference) {
    // Check if user has DeenHub Pro subscription before navigating to references
    if (!_isSubscribed) {
      _showSubscriptionDialog();
      return;
    }

    // Use the app's navigation system based on reference type
    switch (reference.type) {
      case ReferenceType.quran:
        final surah =
            reference.params['surah'] ?? reference.params['surahName'];
        final verse = reference.params['verse'];

        if (surah != null && verse != null) {
          try {
            // Get the Surah by number and navigate to verse view screen
            final quranService = QuranService();
            if (!quranService.isInitialized) {
              context.showSnackBar(
                  'Quran data is still loading. Please try again later.');
              return;
            }

            final surahNumber = int.tryParse(surah.toString());
            final verseNumber = int.tryParse(verse.toString());

            if (surahNumber != null && verseNumber != null) {
              final surahData = quranService.getSurah(surahNumber);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerseViewScreen(
                    surah: surahData,
                    initialVerseId: verseNumber,
                    isMemorizationMode: false,
                    isResultVerse: true,
                  ),
                ),
              );
            }
          } catch (e) {
            context.showErrorSnackBar('Error navigating to Quran: $e');
          }
        }
        break;

      case ReferenceType.hadith:
        // Check if we have the book and hadith IDs at minimum
        final bookId = reference.params['bookId'];
        final hadithId = reference.params['hadithId'];
        final chapterId = reference.params['chapterId'];

        if (bookId != null && hadithId != null) {
          // If we don't have a chapterId, use a default value of 1
          // This is because the detail screen requires a chapterId
          final String chapId = chapterId?.toString() ?? '1';

          // Navigate to Hadith detail screen with specific parameters
          context.pushNamed(Routes.hadithDetail.name, queryParameters: {
            'bookId': bookId.toString(),
            'chapterId': chapId,
            'hadithId': hadithId.toString(),
          });
        } else {
          // Legacy navigation with collection and number
          final collection = reference.params['collection'];
          final number = reference.params['number'];

          if (collection != null && number != null) {
            // Navigate to Hadith viewer (legacy route)
            context.pushNamed(Routes.hadith.name, queryParameters: {
              'collection': collection.toString(),
              'number': number.toString(),
            });
          }
        }
        break;

      case ReferenceType.zakat:
        // Navigate to Zakat calculator
        context.pushNamed(Routes.zakat.name);
        break;

      default:
        // Show a simple message if navigation not possible
        context.showSnackBar('Reference: ${reference.displayText}');
    }
  }

  // Check subscription status - Only DeenHub Pro can access AI features
  Future<void> _checkSubscription() async {
    final isDeenHubProSubscribed = await SubscriptionService.isDeenHubProSubscribed();

    if (mounted) {
      setState(() {
        _isSubscribed = isDeenHubProSubscribed;
        _isLoading = false;
      });
    }

    // If not DeenHub Pro subscriber, redirect to subscription screen
    if (!isDeenHubProSubscribed) {
      // Allow the user to see the screen is loaded before showing the subscription popup
      Future.delayed(const Duration(milliseconds: 300), () {
        _showSubscriptionDialog();
      });
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SubscriptionDialog(),
    );
  }

  // Start the typing animation with staggered delays
  void _startTypingAnimation() {
    _animationController1.repeat(reverse: true);

    // Delay the second dot animation
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted && _isTyping) {
        _animationController2.repeat(reverse: true);
      }
    });

    // Delay the third dot animation
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted && _isTyping) {
        _animationController3.repeat(reverse: true);
      }
    });
  }

  // Stop the typing animation
  void _stopTypingAnimation() {
    _animationController1.stop();
    _animationController2.stop();
    _animationController3.stop();

    _animationController1.reset();
    _animationController2.reset();
    _animationController3.reset();
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: const Color(0xFF2A7A8C)),
            const SizedBox(width: 8),
            const Text('Login Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle,
              color: Color(0xFF2A7A8C),
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'You need to be logged in to use the AI Chatbot feature.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A7A8C),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.pushNamed(Routes.login.name);
            },
            child: const Text(
              'Login Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(ChatMessage message, int messageIndex) {
    // Check if user is logged in
    try {
      final authBloc = getIt<AuthBloc>();
      final isLoggedIn = authBloc.state.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      if (!isLoggedIn) {
        _showLoginRequiredDialog();
        return;
      }
    } catch (e) {
      // If there's an error getting auth status, show login dialog
      logger.e('Error checking authentication status in report dialog: $e');
      _showLoginRequiredDialog();
      return;
    }

    ReportDialog.showAIChatbotReport(
      context,
      messageContent: message.message,
      messageIndex: messageIndex,
      additionalContext: {
        'timestamp': message.timestamp.toIso8601String(),
        'has_references': message.hasReferences,
        'reference_count': message.references.length,
        'session_id': _currentSessionId,
      },
    );
  }

  void _showMonthlyLimitExceededDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Monthly Limit Exceeded').expanded(),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.token,
              color: Colors.orange,
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'You have exceeded your monthly token limit. Please wait until next month to continue using the AI Chatbot.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class SubscriptionDialog extends StatelessWidget {
  const SubscriptionDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Premium Feature',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            color: Color(0xFF2A7A8C),
            size: 50,
          ),
          SizedBox(height: 16),
          Text(
            'DeenGuide AI is available exclusively for DeenHub Pro subscribers.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.pop();
          },
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A7A8C),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            context.pushNamed(Routes.subscription.name);
          },
          child: const Text(
            'Subscribe Now',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
