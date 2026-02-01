import 'package:flutter/material.dart';

class AiChatbotAboutDialog extends StatelessWidget {
  const AiChatbotAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF2A7A8C)),
          SizedBox(width: 8),
          Text(
            "About DeenGuide",
            style: TextStyle(
              color: Color(0xFF2A7A8C),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DeenGuide is an AI assistant designed to help with Islamic questions and knowledge.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text(
            "Features:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AboutDialogFeatureItem(
              text: "Answers questions about Islamic practices"),
          AboutDialogFeatureItem(
              text: "Provides references from Quran and Hadith"),
          AboutDialogFeatureItem(text: "Helps with basic Islamic knowledge"),
          const SizedBox(height: 16),
          const Text(
            "Note: This AI uses ChatGPT and may not be 100% accurate. Always verify important information with qualified Islamic scholars.",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(color: Color(0xFF2A7A8C)),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class AboutDialogFeatureItem extends StatelessWidget {
  const AboutDialogFeatureItem({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF2A7A8C),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
