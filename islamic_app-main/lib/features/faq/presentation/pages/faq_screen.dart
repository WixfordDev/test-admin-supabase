import 'package:flutter/material.dart';
import 'package:deenhub/features/faq/data/models/faq_model.dart';
import 'package:deenhub/features/faq/data/services/faq_service.dart';
import 'package:deenhub/config/themes/styles.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with SingleTickerProviderStateMixin {
  List<FAQModel> _faqs = [];
  List<FAQModel> _categories = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFAQs() async {
    setState(() => _isLoading = true);
    try {
      final faqs = await FAQService.loadFAQs();
      final categories = FAQService.groupByCategory(faqs);
      
      _tabController = TabController(
        length: categories.length,
        vsync: this,
      );
      
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            _selectedCategoryIndex = _tabController.index;
          });
        }
      });
      
      setState(() {
        _faqs = faqs;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Material(
                  color: theme.primaryColor,
                  elevation: 2,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: _categories.map((category) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          category.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories.map((category) {
                      final categoryFAQs = _faqs
                          .where((faq) => faq.category == category.category)
                          .toList();
                          
                      return _buildFAQList(categoryFAQs, theme);
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildFAQList(List<FAQModel> faqs, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return _buildFAQCard(faq, theme, index);
      },
    );
  }
  
  Widget _buildFAQCard(FAQModel faq, ThemeData theme, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        color: theme.cardColor,
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(
              faq.question,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: theme.primaryColor,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              radius: 18,
              child: Text(
                'Q${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.primaryColor,
                ),
              ),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Divider(color: theme.dividerColor),
              gapH8,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    radius: 18,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  gapW12,
                  Expanded(
                    child: Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
