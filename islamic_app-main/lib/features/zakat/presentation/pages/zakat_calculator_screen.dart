import 'package:deenhub/core/notification/services/zakat_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:deenhub/features/zakat/data/models/zakat_faq_model.dart';
import 'package:deenhub/features/zakat/data/services/zakat_faq_service.dart';
import 'package:deenhub/features/quran/data/repository/quran_service.dart';
import 'package:deenhub/features/quran/presentation/quran/pages/verse/verse_view_screen.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/di/app_injections.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  int _selectedTabIndex = 0;

  // Selected currency
  String _selectedCurrency = 'US Dollar (USD)';

  // Selected asset and liability types
  String _selectedAssetType = 'Cash on Hand & Bank Accounts';
  String _selectedLiabilityType = 'Personal Loans';

  // Amount controllers
  final _assetAmountController = TextEditingController();
  final _liabilityAmountController = TextEditingController();

  // Date controller
  final _calculationDateController =
      TextEditingController(text: DateFormat('MM/dd/yyyy').format(DateTime.now()));

  // Metal rate controllers
  final _goldRateController = TextEditingController(text: '65.23');
  final _silverRateController = TextEditingController(text: '0.87');

  // Lists to store added assets and liabilities
  final List<Map<String, dynamic>> _assets = [];
  final List<Map<String, dynamic>> _liabilities = [];

  // Replace _faqItems with new FAQ data structure
  List<ZakatFAQModel> _zakatFAQs = [];
  List<String> _faqCategories = [];
  bool _isLoadingFAQs = true;
  final Map<int, bool> _expandedFAQs = {};

  @override
  void initState() {
    super.initState();
    _loadZakatFAQs();
  }

  Future<void> _loadZakatFAQs() async {
    setState(() => _isLoadingFAQs = true);
    try {
      final faqs = await ZakatFAQService.loadZakatFAQs();
      final categories = ZakatFAQService.getCategories(faqs);
      setState(() {
        _zakatFAQs = faqs;
        _faqCategories = categories;
        _isLoadingFAQs = false;
      });
    } catch (e) {
      setState(() => _isLoadingFAQs = false);
      // Handle error
    }
  }

  // Cache calculated values
  double _cachedTotalAssets = 0;
  double _cachedTotalLiabilities = 0;
  double _cachedNetWorth = 0;
  double _cachedZakat = 0;
  bool _needsRecalculation = true;

  @override
  void dispose() {
    _assetAmountController.dispose();
    _liabilityAmountController.dispose();
    _calculationDateController.dispose();
    _goldRateController.dispose();
    _silverRateController.dispose();
    super.dispose();
  }

  // Get gold rate from input
  double get _goldRatePerGram {
    return double.tryParse(_goldRateController.text) ?? 65.23;
  }

  // Get silver rate from input
  double get _silverRatePerGram {
    return double.tryParse(_silverRateController.text) ?? 0.87;
  }

  // Calculate all values at once to avoid repeated calculations
  void _calculateValues() {
    if (!_needsRecalculation) return;

    _cachedTotalAssets =
        _assets.isEmpty ? 0 : _assets.fold(0, (sum, asset) => sum + (asset['amount'] as double));

    _cachedTotalLiabilities = _liabilities.isEmpty
        ? 0
        : _liabilities.fold(0, (sum, liability) => sum + (liability['amount'] as double));

    _cachedNetWorth = _cachedTotalAssets - _cachedTotalLiabilities;
    _cachedZakat = _cachedNetWorth > 0 ? _cachedNetWorth * 0.025 : 0;

    _needsRecalculation = false;
  }

  // Calculate total assets
  double get _totalAssets {
    _calculateValues();
    return _cachedTotalAssets;
  }

  // Calculate total liabilities
  double get _totalLiabilities {
    _calculateValues();
    return _cachedTotalLiabilities;
  }

  // Calculate net worth
  double get _netWorth {
    _calculateValues();
    return _cachedNetWorth;
  }

  // Calculate zakat (2.5% of net worth)
  double get _zakatAmount {
    _calculateValues();
    return _cachedZakat;
  }

  void _addAsset() {
    if (_assetAmountController.text.isEmpty) return;

    double amount = double.tryParse(_assetAmountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() {
      _assets.add({
        'type': _selectedAssetType,
        'amount': amount,
      });
      _assetAmountController.clear();
      _needsRecalculation = true;
    });
  }

  void _addLiability() {
    if (_liabilityAmountController.text.isEmpty) return;

    double amount = double.tryParse(_liabilityAmountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() {
      _liabilities.add({
        'type': _selectedLiabilityType,
        'amount': amount,
      });
      _liabilityAmountController.clear();
      _needsRecalculation = true;
    });
  }

  void _toggleFAQ(int index) {
    setState(() {
      _expandedFAQs[index] = !(_expandedFAQs[index] ?? false);
    });
  }

  void _navigateToReference(String type, dynamic reference) {
    if (type == 'Quran') {
      // Navigate to Quran section with surahNumber and verseNumber
      final quranRef = reference as QuranReference;

      try {
        // Get the Surah by number and navigate to verse view screen
        final quranService = QuranService();
        if (!quranService.isInitialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quran data is still loading. Please try again later.'),
            ),
          );
          return;
        }

        final surah = quranService.getSurah(quranRef.surahNumber);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerseViewScreen(
              surah: surah,
              initialVerseId: quranRef.verseNumber,
              isMemorizationMode: false,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to Quran: $e'),
          ),
        );
      }
    } else if (type == 'Hadith') {
      // Navigate to Hadith section
      final hadithRef = reference as HadithReference;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to Hadith: ${hadithRef.source}'),
        ),
      );

      // TODO: Implement actual navigation to Hadith section
    }
  }

  Future<void> _scheduleZakatReminder() async {
    try {
      // Check if user is logged in
      final prefsHelper = getIt<SharedPrefsHelper>();
      if (!prefsHelper.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to set Zakat reminders'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show date picker to select Zakat reminder date
      final DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 5),
        helpText: 'Select your annual Zakat calculation date',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF2A7A8C),
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedDate == null) {
        return; // User cancelled the date picker
      }

      // Set the reminder time to 9:00 AM on the selected date
      final reminderDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        9, // 9 AM
        0, // 0 minutes
      );

      // Cancel any existing Zakat reminder
      await getIt<ZakatNotificationService>().cancelZakatReminder();

      // Schedule new reminder
      await getIt<ZakatNotificationService>().scheduleZakatReminder(
        reminderDate: reminderDateTime,
        zakatAmount: _zakatAmount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Zakat reminder set for ${DateFormat('MMM dd, yyyy').format(reminderDateTime)} at 9:00 AM',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: 'Zakat Calculator',
      automaticallyImplyLeading: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH8,
          Text(
            'Calculate your obligatory charity (Zakat) based on your assets, liabilities, and the current Nisab threshold.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ).withPadding(px16),
          gapH8,
          // Tabs at the top
          _buildTabs(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTabContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(0, 'Calculator', Icons.calculate_outlined),
          ),
          Expanded(
            child: _buildTabButton(1, 'FAQ', Icons.help_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAssetsSection(),
          gapH16,
          _buildLiabilitiesSection(),
          gapH16,
          _buildCalculateZakatSection(),
          gapH16,
          _buildEligibleRecipientsSection(),
          gapH16,
          _buildCalculationWarning(),
        ],
      );
    } else {
      return _buildFAQContent();
    }
  }

  Widget _buildFAQContent() {
    if (_isLoadingFAQs) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            gapH16,
            Text(
              'Loading Zakat knowledge...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_zakatFAQs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            gapH16,
            Text(
              'No FAQ data available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            gapH8,
            ElevatedButton(
              onPressed: _loadZakatFAQs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zakat Knowledge Base',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          gapH8,
          Text(
            'Explore Islamic guidance on Zakat with references from the Quran and Hadith.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          gapH24,
      
          // Category tabs
          _buildCategoryTabs(),
          gapH16,
      
          // FAQs for the selected category
          ..._faqCategories.isEmpty
              ? [const SizedBox.shrink()]
              : _buildFAQsForCategory(_faqCategories[_selectedCategoryIndex]),
        ],
      ),
    );
  }

  // Build category tabs
  int _selectedCategoryIndex = 0;

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _faqCategories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2A7A8C) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  _faqCategories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build FAQs for a specific category
  List<Widget> _buildFAQsForCategory(String category) {
    final categoryFAQs = _zakatFAQs.where((faq) => faq.category == category).toList();

    return [
      ...categoryFAQs.asMap().entries.map((entry) {
        final index = entry.key;
        final faq = entry.value;
        final isExpanded = _expandedFAQs[index] ?? false;

        return Card(
          elevation: isExpanded ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Question section
              InkWell(
                onTap: () => _toggleFAQ(index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF2A7A8C),
                      ),
                    ],
                  ),
                ),
              ),

              // Answer section (expanded)
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      gapH8,
                      Text(
                        faq.answer,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                      if (faq.quranReference != null || faq.hadithReference != null) gapH16,

                      // References section with an icon and title
                      if (faq.quranReference != null || faq.hadithReference != null)
                        Row(
                          children: [
                            const Icon(Icons.menu_book, size: 18, color: Colors.grey),
                            gapW8,
                            const Text(
                              'References',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      if (faq.quranReference != null || faq.hadithReference != null) gapH8,

                      // Quran reference
                      if (faq.quranReference != null)
                        _buildReferenceCard(
                          title: 'Quran Reference',
                          subtitle:
                              '${faq.quranReference!.surah} (${faq.quranReference!.surahNumber}:${faq.quranReference!.verseNumber})',
                          quote: faq.quranReference!.quote,
                          color: Colors.green,
                          icon: Icons.auto_stories,
                          onTap: () => _navigateToReference('Quran', faq.quranReference!),
                        ),

                      if (faq.quranReference != null && faq.hadithReference != null) gapH8,

                      // Hadith reference
                      if (faq.hadithReference != null)
                        _buildReferenceCard(
                          title: 'Hadith Reference',
                          subtitle: faq.hadithReference!.source,
                          quote: faq.hadithReference!.quote,
                          color: Colors.orange,
                          icon: Icons.history_edu,
                          onTap: () => _navigateToReference('Hadith', faq.hadithReference!),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    ];
  }

  // Build a reference card with a title, quote, and tap action
  Widget _buildReferenceCard({
    required String title,
    required String subtitle,
    required String quote,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference header
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  gapW8,
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              gapH4,
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
              gapH8,

              // Quote
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  quote,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ),

              // Tap indicator
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tap to view',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable style constants
  final _cardBorderRadius = BorderRadius.circular(12);
  final _inputBorderRadius = BorderRadius.circular(8);

  // Reusable text styles
  final _sectionTitleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final _labelStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  final _amountStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  // Reusable decoration
  InputDecoration _buildInputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: _inputBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _inputBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildAssetsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: _cardBorderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Assets',
                  style: _sectionTitleStyle.copyWith(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Currency selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Currency', style: _labelStyle),
                gapH8,
                _buildDropdown(
                  value: _selectedCurrency,
                  items: ['US Dollar (USD)', 'Euro (EUR)', 'British Pound (GBP)'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                  itemBuilder: (value) {
                    return Row(
                      children: [
                        Text(
                          value.contains('USD')
                              ? '\$ '
                              : value.contains('EUR')
                                  ? '€ '
                                  : '£ ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(value),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Add new asset form
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Asset',
                  style: _sectionTitleStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Asset type dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Asset Type', style: _labelStyle),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedAssetType,
                      items: [
                        'Cash on Hand & Bank Accounts',
                        'Gold & Silver',
                        'Stocks & Investments',
                        'Business Assets',
                        'Real Estate (for Trade)',
                        'Other Assets'
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAssetType = value;
                          });
                        }
                      },
                    ),
                  ],
                ),

                gapH16,

                // Amount field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount (\$)', style: _labelStyle),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _assetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(hintText: 'Amount'),
                    ),
                  ],
                ),

                gapH16,

                // Add Asset button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add Asset'),
                    onPressed: _addAsset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: _inputBorderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Your Assets section
          Container(
            color: Colors.white,
            padding: px16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Assets',
                  style: _sectionTitleStyle.copyWith(fontSize: 16),
                ),
                if (_assets.isEmpty)
                  _buildEmptyState('No assets added yet')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _assets.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final asset = _assets[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(asset['type']),
                        trailing: Text(
                          '\$${asset['amount'].toStringAsFixed(2)}',
                          style: _amountStyle,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilitiesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: _cardBorderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: Colors.red.shade300),
                const SizedBox(width: 8),
                Text(
                  'Liabilities',
                  style: _sectionTitleStyle.copyWith(color: Colors.red.shade300),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Liability type
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Liability Type', style: _labelStyle),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedLiabilityType,
                  items: [
                    'Personal Loans',
                    'Credit Card Debt',
                    'Mortgage',
                    'Business Liabilities',
                    'Other Debts'
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLiabilityType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Amount field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount (\$)', style: _labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _liabilityAmountController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(hintText: 'Amount'),
                ),

                const SizedBox(height: 16),

                // Add Liability button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add Liability'),
                    onPressed: _addLiability,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: _inputBorderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Your Liabilities section
          Container(
            color: Colors.white,
            padding: px16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Liabilities',
                  style: _sectionTitleStyle.copyWith(fontSize: 16),
                ),
                if (_liabilities.isEmpty)
                  _buildEmptyState('No liabilities added yet')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _liabilities.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final liability = _liabilities[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(liability['type']),
                        trailing: Text(
                          '\$${liability['amount'].toStringAsFixed(2)}',
                          style: _amountStyle,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateZakatSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: _cardBorderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calculate_outlined, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Calculate Zakat',
                  style: _sectionTitleStyle.copyWith(color: Colors.purple.shade700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Calculation Date
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calculation Date', style: _labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _calculationDateController,
                  readOnly: true,
                  decoration: _buildInputDecoration(
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (picked != null) {
                      setState(() {
                        _calculationDateController.text = DateFormat('MM/dd/yyyy').format(picked);
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Current Metal Rates Input
          Container(
            color: Colors.purple.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Metal Rates',
                  style: _labelStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Note about manual updates
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade800,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: Gold and silver prices are not auto-updated. Please enter the current rates based on your local market.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Gold rate input
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Gold Rate (\$/gram):',
                        style: _labelStyle,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _goldRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _buildInputDecoration(hintText: '65.23'),
                        onChanged: (value) => setState(() {}), // Trigger recalculation
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Silver rate input
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Silver Rate (\$/gram):',
                        style: _labelStyle,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _silverRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _buildInputDecoration(hintText: '0.87'),
                        onChanged: (value) => setState(() {}), // Trigger recalculation
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: _sectionTitleStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Total Assets:', '\$${_totalAssets.toStringAsFixed(2)}'),
                _buildSummaryRow('Total Liabilities:', '\$${_totalLiabilities.toStringAsFixed(2)}'),
                _buildSummaryRow('Net Worth:', '\$${_netWorth.toStringAsFixed(2)}'),
                _buildSummaryRow(
                  'Zakat (2.5%):',
                  '\$${_zakatAmount.toStringAsFixed(2)}',
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable dropdown widget
  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    Widget Function(T)? itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: _inputBorderRadius,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder != null ? itemBuilder(item) : Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCalculationWarning() {
    return Text(
      'This calculation is based on the information you provided and is for guidance only. '
      'For specific cases, please consult with a knowledgeable Islamic scholar or financial advisor.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEligibleRecipientsSection() {
    // List of eligible Zakat recipients
    final List<String> recipients = [
      'The poor (Fuqara)',
      'The needy (Masakeen)',
      'Zakat administrators',
      'Those whose hearts are to be reconciled',
      'Those in bondage (slaves and captives)',
      'The debt-ridden',
      'In the cause of Allah (Fee Sabeelillah)',
      'The wayfarer (stranded traveler)',
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: _cardBorderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eligible Zakat Recipients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          gapH8,
          Text(
            'According to Islamic guidelines, Zakat should be distributed among these categories:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          gapH8,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 6,
            ),
            itemCount: recipients.length,
            itemBuilder: (context, index) {
              return _buildRecipientChip(recipients[index]);
            },
          ),
          gapH8,
          ElevatedButton.icon(
            icon: const Icon(Icons.favorite_outline, size: 18),
            label: const Text('Donate Zakat'),
            onPressed: () {
              // Handle donation button press
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donation feature will be available soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A7A8C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ).center(),
          gapH4,
                      OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text('Set Reminder for Next Year'),
            onPressed: _scheduleZakatReminder,
          ).center(),
        ],
      ).withPadding(p16),
    );
  }

  Widget _buildRecipientChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
