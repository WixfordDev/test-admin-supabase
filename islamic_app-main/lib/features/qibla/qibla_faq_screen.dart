import 'package:flutter/material.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/qibla/data/providers/qibla_faq_provider.dart';
import 'package:deenhub/features/qibla/domain/models/qibla_faq.dart';

class QiblaFaqScreen extends StatefulWidget {
  const QiblaFaqScreen({super.key});

  @override
  State<QiblaFaqScreen> createState() => _QiblaFaqScreenState();
}

class _QiblaFaqScreenState extends State<QiblaFaqScreen> {
  final QiblaFaqProvider _faqProvider = QiblaFaqProvider();
  late List<QiblaFaq> _faqs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() => _isLoading = true);
    try {
      _faqs = _faqProvider.getFaqs();
    } catch (e) {
      debugPrint('Error loading FAQs: $e');
      _faqs = [];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBarScaffold(
      pageTitle: 'Qibla FAQ',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(colorScheme),
                    const SizedBox(height: 24),
                    _buildFaqList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.question_answer_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Qibla Finder FAQ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Find answers to commonly asked questions about our Qibla finder feature.',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    if (_faqs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No FAQs available at the moment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _faqs.length,
      itemBuilder: (context, index) => _buildFaqItem(_faqs[index], index),
    );
  }

  Widget _buildFaqItem(QiblaFaq faq, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: faq.isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                faq.isExpanded = expanded;
              });
            },
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: EdgeInsets.zero,
            backgroundColor: theme.cardColor,
            collapsedBackgroundColor: theme.cardColor,
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: faq.isExpanded
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.surfaceVariant.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: AnimatedRotation(
                turns: faq.isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: faq.isExpanded
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            title: Text(
              faq.question,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                color: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}