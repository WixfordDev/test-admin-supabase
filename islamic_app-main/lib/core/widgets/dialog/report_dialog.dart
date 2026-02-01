import 'package:flutter/material.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/report_service.dart';
import 'package:deenhub/main.dart';
import 'package:deenhub/config/themes/styles.dart';

class ReportDialog {
  static Future<void> showAIChatbotReport(
    BuildContext context, {
    required String messageContent,
    required int messageIndex,
    Map<String, dynamic>? additionalContext,
  }) async {
    await _showReportBottomSheet(
      context,
      reportType: ReportType.aiChatbot,
      title: 'Report AI Message',
      subtitle: 'Help us improve by reporting issues with this AI response',
      contentPreview: messageContent,
      onSubmit: (category, title, description) async {
        final request = CreateReportRequest.aiChatbot(
          category: category,
          title: title,
          description: description,
          messageContent: messageContent,
          messageIndex: messageIndex,
          additionalContext: additionalContext,
        );
        return await getIt<ReportService>().submitReport(request);
      },
    );
  }

  static Future<void> showAIExplanationReport(
    BuildContext context, {
    required String explanation,
    required int surahNumber,
    required int verseNumber,
    Map<String, dynamic>? additionalContext,
  }) async {
    await _showReportBottomSheet(
      context,
      reportType: ReportType.aiExplanation,
      title: 'Report AI Explanation',
      subtitle: 'Report issues with this verse explanation',
      contentPreview: explanation,
      onSubmit: (category, title, description) async {
        final request = CreateReportRequest.aiExplanation(
          category: category,
          title: title,
          description: description,
          explanation: explanation,
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          additionalContext: additionalContext,
        );
        return await getIt<ReportService>().submitReport(request);
      },
    );
  }

  static Future<void> showHadithReport(
    BuildContext context, {
    required String hadithId,
    required String bookId,
    Map<String, dynamic>? hadithData,
    Map<String, dynamic>? additionalContext,
  }) async {
    await _showReportBottomSheet(
      context,
      reportType: ReportType.hadith,
      title: 'Report Hadith Content',
      subtitle: 'Report issues with this hadith',
      contentPreview: hadithData?['text_en'] ?? 'Hadith content',
      onSubmit: (category, title, description) async {
        final request = CreateReportRequest.hadith(
          category: category,
          title: title,
          description: description,
          hadithId: hadithId,
          bookId: bookId,
          additionalContext: {
            ...?additionalContext,
            'hadith_data': hadithData,
          },
        );
        return await getIt<ReportService>().submitReport(request);
      },
    );
  }

  static Future<void> _showReportBottomSheet(
    BuildContext context, {
    required ReportType reportType,
    required String title,
    required String subtitle,
    required String contentPreview,
    required Future<String> Function(ReportCategory, String, String?) onSubmit,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: ReportBottomSheet(
          reportType: reportType,
          title: title,
          subtitle: subtitle,
          contentPreview: contentPreview,
          onSubmit: onSubmit,
        ),
      ),
    );
  }
}

class ReportBottomSheet extends StatefulWidget {
  final ReportType reportType;
  final String title;
  final String subtitle;
  final String contentPreview;
  final Future<String> Function(ReportCategory, String, String?) onSubmit;

  const ReportBottomSheet({
    super.key,
    required this.reportType,
    required this.title,
    required this.subtitle,
    required this.contentPreview,
    required this.onSubmit,
  });

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  ReportCategory? _selectedCategory;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        _selectedCategory!,
        _titleController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessBottomSheet(context);
      }
    } catch (e) {
      logger.e('Error submitting report: $e');
      if (mounted) {
        _showErrorBottomSheet(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _ReportBottomSheetHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContentPreviewWidget(content: widget.contentPreview),
                    gapH24,
                    _CategorySectionWidget(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                          // Auto-generate title based on category
                          _titleController.text = _getDefaultTitle(category);
                        });
                      },
                    ),
                    gapH24,
                    _TitleInputWidget(
                      controller: _titleController,
                      selectedCategory: _selectedCategory,
                    ),
                    gapH16,
                    _DescriptionInputWidget(
                      controller: _descriptionController,
                      onSubmit: _submitReport,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _SubmitButtonWidget(
            isSubmitting: _isSubmitting,
            isValid: _selectedCategory != null && _titleController.text.isNotEmpty,
            onSubmit: _submitReport,
          ),
        ],
      ),
    );
  }

  String _getDefaultTitle(ReportCategory category) {
    switch (category) {
      case ReportCategory.incorrectInformation:
        return 'Incorrect information provided';
      case ReportCategory.inappropriateContent:
        return 'Inappropriate content detected';
      case ReportCategory.misleadingGuidance:
        return 'Misleading religious guidance';
      case ReportCategory.technicalError:
        return 'Technical error encountered';
      case ReportCategory.inconsistency:
        return 'Content inconsistency found';
      case ReportCategory.offensiveContent:
        return 'Offensive content reported';
      case ReportCategory.other:
        return 'General issue report';
    }
  }

  static void _showSuccessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(child: const _SuccessBottomSheet()),
    );
  }

  static void _showErrorBottomSheet(BuildContext context, String error) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(child: _ErrorBottomSheet(error: error)),
    );
  }
}

class _ReportBottomSheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _ReportBottomSheetHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A7A8C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          gapH16,
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: Colors.white,
                size: 24,
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    gapH4,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentPreviewWidget extends StatelessWidget {
  final String content;

  const _ContentPreviewWidget({required this.content});

  @override
  Widget build(BuildContext context) {
    final previewText = content.length > 150 
        ? '${content.substring(0, 150)}...' 
        : content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                size: 16,
                color: Colors.grey.shade600,
              ),
              gapW8,
              Text(
                'Content Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          gapH12,
          Text(
            previewText,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySectionWidget extends StatelessWidget {
  final ReportCategory? selectedCategory;
  final Function(ReportCategory) onCategorySelected;

  const _CategorySectionWidget({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category,
              size: 18,
              color: const Color(0xFF2A7A8C),
            ),
            gapW8,
            Text(
              'What\'s the issue?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        gapH16,
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: ReportCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return _CategoryChip(
              category: category,
              isSelected: isSelected,
              onSelected: () => onCategorySelected(category),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ReportCategory category;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF2A7A8C) 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF2A7A8C) 
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF2A7A8C).withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white,
              ),
                             gapW4,
            ],
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final ReportCategory? selectedCategory;

  const _TitleInputWidget({
    required this.controller,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.title,
              size: 18,
              color: const Color(0xFF2A7A8C),
            ),
            gapW8,
            Text(
              'Report Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        gapH12,
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: selectedCategory != null 
                ? 'Brief description of the issue' 
                : 'Please select a category first',
            enabled: selectedCategory != null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A7A8C), width: 2),
            ),
            filled: true,
            fillColor: selectedCategory != null 
                ? Colors.white 
                : Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title for your report';
            }
            if (value.trim().length < 5) {
              return 'Title must be at least 5 characters long';
            }
            return null;
          },
          maxLength: 100,
        ),
      ],
    );
  }
}

class _DescriptionInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _DescriptionInputWidget({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description,
              size: 18,
              color: const Color(0xFF2A7A8C),
            ),
            gapW8,
            Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' (Optional)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        gapH12,
        TextFormField(
          controller: controller,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            hintText: 'Provide more details about the issue (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A7A8C), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLength: 500,
        ),
      ],
    );
  }
}

class _SubmitButtonWidget extends StatelessWidget {
  final bool isSubmitting;
  final bool isValid;
  final VoidCallback onSubmit;

  const _SubmitButtonWidget({
    required this.isSubmitting,
    required this.isValid,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isSubmitting || !isValid ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A7A8C),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isValid ? 2 : 0,
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Submit Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isValid ? Colors.white : Colors.grey.shade600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessBottomSheet extends StatelessWidget {
  const _SuccessBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 48,
            ),
          ),
          gapH24,
          Text(
            'Report Submitted Successfully',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          gapH12,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Thank you for your feedback. We\'ll review your report and take appropriate action.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          gapH24,
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A7A8C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBottomSheet extends StatelessWidget {
  final String error;

  const _ErrorBottomSheet({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error,
              color: Colors.red.shade600,
              size: 48,
            ),
          ),
          gapH24,
          Text(
            'Failed to Submit Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          gapH12,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'There was an error submitting your report. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          gapH16,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Error: ${error.length > 100 ? '${error.substring(0, 100)}...' : error}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          gapH24,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              gapW16,
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Could potentially retry here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A7A8C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 