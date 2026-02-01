import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/chat_message.dart';
import 'package:deenhub/features/ai_chatbot/domain/models/reference_detector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageInputField extends StatelessWidget {
  const MessageInputField({
    super.key,
    required this.context,
    required this.messageController,
    required this.isTyping,
    required this.onSend,
  });

  final BuildContext context;
  final TextEditingController messageController;
  final bool isTyping;
  final Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Ask about Islam...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.question_answer_outlined,
                    color: Color(0xFF2A7A8C),
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: isTyping ? Colors.grey : const Color(0xFF2A7A8C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              onPressed: isTyping ? null : () => onSend(),
              icon: isTyping
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({
    super.key,
    required this.context,
    required this.message,
    required this.index,
    required this.onReferenceTap,
    required this.onReportTap,
  });

  final BuildContext context;
  final ChatMessage message;
  final int index;
  final Function(IslamicReference) onReferenceTap;
  final Function(ChatMessage, int) onReportTap;

  @override
  Widget build(BuildContext context) {
    final isFirstBotMessage = index == 0 && !message.isUser;

    return Column(
      children: [
        if (index > 0) const SizedBox(height: 16),
        Align(
          alignment:
              message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bot avatar for bot messages
              if (!message.isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A7A8C), Color(0xFF3A8A9C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A7A8C).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
              // Message content
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: message.isUser
                      ? const EdgeInsets.fromLTRB(16, 12, 16, 12)
                      : const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : isFirstBotMessage
                            ? const Color(0xFFF5F9FA)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: message.isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: message.isUser ? 0.1 : 0.05),
                        blurRadius: message.isUser ? 4 : 8,
                        spreadRadius: message.isUser ? 0 : 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: message.isUser
                        ? null
                        : Border.all(
                            color: const Color(0xFFEAEFF0),
                            width: 1,
                          ),
                    gradient: !message.isUser && !isFirstBotMessage
                        ? LinearGradient(
                            colors: [
                              Colors.white,
                              const Color(0xFFF8FBFC),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Special styling for welcome message
                      if (isFirstBotMessage)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF2A7A8C).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Welcome to DeenGuide",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF2A7A8C),
                            ),
                          ),
                        ),
                      // Message text with formatting
                      MessageText(
                          message: message.message,
                          isUser: message.isUser,
                          isFirstBotMessage: isFirstBotMessage),

                      // Show references if present for bot messages
                      if (message.hasReferences && !message.isUser)
                        ReferenceButtons(
                            references: message.references,
                            onReferenceTap: onReferenceTap),

                      gapH6,
                      // Timestamp and actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color: message.isUser
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : const Color(0xFF2A7A8C)
                                        .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('h:mm a').format(message.timestamp),
                                style: TextStyle(
                                  color: message.isUser
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : const Color(0xFF2A7A8C)
                                          .withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          // Report button for bot messages
                          if (!message.isUser && !isFirstBotMessage)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A7A8C)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2A7A8C)
                                      .withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => onReportTap(message, index),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: 14,
                                        color: const Color(0xFF2A7A8C)
                                            .withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Report',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: const Color(0xFF2A7A8C)
                                              .withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // User avatar for user messages
              if (message.isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8, bottom: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.primary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Updated method to handle text formatting including bold text
class MessageText extends StatelessWidget {
  const MessageText({
    super.key,
    required this.message,
    required this.isUser,
    required this.isFirstBotMessage,
  });

  final String message;
  final bool isUser;
  final bool isFirstBotMessage;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // Improved regex for disclaimer detection
        final disclaimerPattern = RegExp(
            r'(DISCLAIMER\s*:|WARNING\s*:|NOTE\s*:)',
            caseSensitive: false);
        final hasDisclaimer = disclaimerPattern.hasMatch(message);

        // If there is a disclaimer, split the message to handle it separately
        if (hasDisclaimer) {
          final match = disclaimerPattern.firstMatch(message);
          if (match != null) {
            final splitIndex = match.start;
            final mainText = message.substring(0, splitIndex);
            final disclaimerText = message.substring(splitIndex);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main text with regular formatting
                FormattedMessageText(
                    text: mainText,
                    isUser: isUser,
                    isFirstBotMessage: isFirstBotMessage),
                // Disclaimer text in red bold
                FormattedMessageText(
                    text: disclaimerText,
                    isUser: isUser,
                    isFirstBotMessage: isFirstBotMessage,
                    isDisclaimer: true),
              ],
            );
          }
        }

        // No disclaimer, handle regular formatting
        return FormattedMessageText(
            text: message,
            isUser: isUser,
            isFirstBotMessage: isFirstBotMessage);
      },
    );
  }
}

// Helper method to build formatted text with proper handling of asterisks
class FormattedMessageText extends StatelessWidget {
  const FormattedMessageText({
    super.key,
    required this.text,
    required this.isUser,
    required this.isFirstBotMessage,
    this.isDisclaimer = false,
  });
  final String text;
  final bool isUser;
  final bool isFirstBotMessage;
  final bool isDisclaimer;

  @override
  Widget build(BuildContext context) {
    // Process text with asterisks for bold formatting
    // This handles both single asterisk (*word*) and double asterisk (**word**)
    // Works even if our system converted * to **
    final List<TextSpan> textSpans = [];

    // Normalize the format - convert **** to ** to handle the double conversion issue
    final normalizedText = text.replaceAll('****', '**');

    // Split the text by ** (which marks bold text)
    final parts = normalizedText.split('**');

    bool isBold = false;
    for (var part in parts) {
      if (part.isNotEmpty) {
        textSpans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              color: isDisclaimer
                  ? Colors.red
                  : isUser
                      ? Colors.white
                      : isFirstBotMessage
                          ? const Color(0xFF2A7A8C)
                          : Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              height: 1.4,
              fontWeight:
                  isBold || isDisclaimer ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }
      // Toggle bold state for next iteration
      isBold = !isBold;
    }

    // Use RichText for formatted text display
    return RichText(
      text: TextSpan(children: textSpans),
      textAlign: TextAlign.start,
      softWrap: true,
      overflow: TextOverflow.visible,
    );
  }
}

class ReferenceButtons extends StatelessWidget {
  final List<IslamicReference> references;
  final Function(IslamicReference) onReferenceTap;

  const ReferenceButtons(
      {super.key, required this.references, required this.onReferenceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: references.map((reference) {
          // Different styling based on reference type
          Color bgColor;
          Color textColor;
          IconData iconData;

          switch (reference.type) {
            case ReferenceType.quran:
              bgColor = const Color(0xFFE8F3E8); // Light green for Quran
              textColor = const Color(0xFF2E7D32); // Dark green for Quran
              iconData = Icons.menu_book_rounded; // Book icon for Quran
              break;
            case ReferenceType.hadith:
              bgColor = const Color(0xFFECF0F9); // Light blue for Hadith
              textColor = const Color(0xFF1565C0); // Dark blue for Hadith
              iconData = Icons.format_quote_rounded; // Quote icon for Hadith
              break;
            case ReferenceType.zakat:
              bgColor = const Color(0xFFFFF8E1); // Light amber for Zakat
              textColor = const Color(0xFFFF8F00); // Amber for Zakat
              iconData = Icons.calculate_rounded; // Calculator icon for Zakat
              break;
            default:
              bgColor = Colors.grey.shade200;
              textColor = Colors.grey.shade700;
              iconData = Icons.link;
          }

          return InkWell(
            onTap: () => onReferenceTap(reference),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconData,
                    size: 14,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reference.displayText,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
