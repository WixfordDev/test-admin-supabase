import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/subscription/presentation/pages/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/core/services/ai_usage/ai_usage_tracking_service.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/subscription_product.dart';
import '../bloc/subscription_bloc.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late final SubscriptionBloc _subscriptionBloc;
  final AuthBloc _authBloc = getIt<AuthBloc>();
  String? _selectedProductId;
  bool _isLoggedIn = false;
  SubscriptionPlan? _currentPlan;
  bool _isLoadingCurrentPlan = true;
  SubscriptionPeriod _selectedPeriod = SubscriptionPeriod.yearly;
  String? _currentSubscriptionPeriod;

  @override
  void initState() {
    super.initState();
    _subscriptionBloc = SubscriptionBloc(getIt<SubscriptionService>());
    _checkAuthStatus();
    _loadCurrentPlan();
    _subscriptionBloc.add(const SubscriptionEvent.initialize());
    _subscriptionBloc.add(const SubscriptionEvent.loadProducts());
  }

  @override
  void dispose() {
    _subscriptionBloc.close();
    super.dispose();
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final usageTracker = AIUsageTrackingService();
      final currentPlan = await usageTracker.getCurrentPlan();
      final prefs = await SharedPreferences.getInstance();
      final currentPeriod = prefs.getString('subscriptionPeriod') ?? 'monthly';

      if (mounted) {
        setState(() {
          _currentPlan = currentPlan;
          _currentSubscriptionPeriod = currentPeriod;
          _isLoadingCurrentPlan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCurrentPlan = false;
        });
      }
    }
  }

  void _checkAuthStatus() {
    _isLoggedIn = _authBloc.state.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    );

    if (!_isLoggedIn) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showLoginRequiredDialog();
        }
      });
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Login Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              'You need to be logged in before subscribing to premium features.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This allows us to associate your subscription with your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pushNamed(Routes.login.name);
            },
            child: const Text('Login Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        systemOverlayStyle: DecorationStyles.appBarSystemUiOverlayStyle(
          appBarColor: context.primaryColor,
        ),
        title: const Text('Choose Your Plan'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
          bloc: _subscriptionBloc,
          listener: (context, state) {
            // Show error messages
            if (state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // Handle successful purchase
            if (state.isPurchaseCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Your subscription is now active.'),
                  backgroundColor: Colors.green,
                ),
              );

              // Reload current plan to reflect changes
              _loadCurrentPlan();

              // Navigate back after successful purchase
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
            }
          },
          builder: (context, state) {
            if ((state.isLoading && state.products.isEmpty) || _isLoadingCurrentPlan) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Unable to load subscription products'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _subscriptionBloc.add(
                        const SubscriptionEvent.loadProducts(),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            // Filter products by selected period
            final filtered = _filterProductsByPeriod(state.products);

            // Check if user has active subscription
            final hasActiveSubscription =
                _currentPlan != null &&
                    (_currentPlan!.name == 'Quran Lite' ||
                        _currentPlan!.name == 'DeenHub Pro' ||
                        _currentPlan!.name == 'Barakah Access');

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildHeaderSection(),
                              const SizedBox(height: 16),
                              _buildBillingToggle(),
                              if (hasActiveSubscription) ...[
                                const SizedBox(height: 16),
                                _buildCurrentSubscriptionSection(),
                              ],
                              const SizedBox(height: 32),
                              _buildSubscriptionPlans(filtered, hasActiveSubscription),
                              const SizedBox(height: 24),
                              _buildMissionStatement(),
                              const SizedBox(height: 150),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.isPurchaseInProgress)
                  Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                _buildBottomSection(state, filtered),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Text(
          '🕌 DeenHub',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the plan that best fits your spiritual journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlans(
      List<SubscriptionProduct> products,
      bool hasActiveSubscription,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Types',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...products.map((product) {
          final isDisabled = _shouldDisableProduct(product);
          final isCurrent = _isCurrentSubscription(product);

          return Column(
            children: [
              SubscriptionCard(
                product: product,
                isSelected: _selectedProductId == product.id,
                isDisabled: isDisabled,
                isCurrent: isCurrent,
                onTap: isDisabled
                    ? null
                    : () {
                  setState(() {
                    _selectedProductId = product.id;
                  });
                },
              ),
              if (product != products.last) const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMissionStatement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mission Statement',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🕌 DeenHub is a nonprofit project',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"We believe access to the Quran should never depend on money. That\'s why we offer free access to anyone who needs it — no questions asked. Your subscription helps us keep that promise."',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
      SubscriptionState state,
      List<SubscriptionProduct> displayProducts,
      ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedProductId == null ||
                    state.isPurchaseInProgress ||
                    !_isLoggedIn)
                    ? null
                    : () async {
                  final selectedProduct = displayProducts.firstWhere(
                        (p) => p.id == _selectedProductId,
                    orElse: () => displayProducts.first,
                  );

                  if (selectedProduct.type == SubscriptionType.barakahAccess) {
                    await _handleBarakahAccess();
                  } else {
                    _subscriptionBloc.add(
                      SubscriptionEvent.purchase(selectedProduct),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  state.isPurchaseInProgress
                      ? 'Processing...'
                      : !_isLoggedIn
                      ? 'Login Required'
                      : _selectedProductId != null &&
                      displayProducts
                          .firstWhere(
                            (p) => p.id == _selectedProductId,
                        orElse: () => displayProducts.first,
                      )
                          .type ==
                          SubscriptionType.barakahAccess
                      ? 'Enable Free Access'
                      : 'Continue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: state.isRestoringPurchases || !_isLoggedIn
                  ? null
                  : () {
                _subscriptionBloc.add(
                  const SubscriptionEvent.restorePurchases(),
                );
              },
              child: Text(
                state.isRestoringPurchases
                    ? 'Restoring...'
                    : 'Restore Purchases',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SubscriptionProduct> _filterProductsByPeriod(
      List<SubscriptionProduct> all,
      ) {
    return all.where((p) => p.period == _selectedPeriod).toList();
  }

  Future<void> _handleBarakahAccess() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barakah Access'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are requesting free access to the Quran.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              '"We trust your intention. If you\'re genuinely unable to pay, consider it a gift. Allah knows best and is a sufficient witness."',
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Note: Barakah Access includes basic Quran features but does not include AI-powered features.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Do you acknowledge this statement?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('I Acknowledge'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Show loading
      setState(() {});

      final subscriptionService = getIt<SubscriptionService>();
      final success = await subscriptionService.subscribeToBarakahAccess();

      if (success && mounted) {
        // Reload current plan
        await _loadCurrentPlan();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barakah Access enabled. May Allah bless you.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to enable Barakah Access. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  SubscriptionType? _getCurrentSubscriptionType(String planName) {
    switch (planName) {
      case 'Barakah Access':
        return SubscriptionType.barakahAccess;
      case 'Quran Lite':
        return SubscriptionType.quranLite;
      case 'DeenHub Pro':
        return SubscriptionType.deenhubPro;
      default:
        return null;
    }
  }

  bool _shouldDisableProduct(SubscriptionProduct product) {
    if (_currentPlan == null) return false;

    final currentType = _getCurrentSubscriptionType(_currentPlan!.name);
    if (currentType == null) return false;

    // If it's the exact same subscription, disable it
    if (_isCurrentSubscription(product)) return true;

    // Disable lower tier subscriptions
    switch (currentType) {
      case SubscriptionType.deenhubPro:
        return product.type == SubscriptionType.barakahAccess ||
            product.type == SubscriptionType.quranLite;
      case SubscriptionType.quranLite:
        return product.type == SubscriptionType.barakahAccess;
      case SubscriptionType.barakahAccess:
        return false;
    }
  }

  bool _isCurrentSubscription(SubscriptionProduct product) {
    if (_currentPlan == null) return false;

    final currentType = _getCurrentSubscriptionType(_currentPlan!.name);
    if (currentType == null) return false;

    if (currentType != product.type) return false;

    final currentPeriod = _currentSubscriptionPeriod ?? 'monthly';
    final productPeriod = product.period == SubscriptionPeriod.yearly
        ? 'yearly'
        : 'monthly';

    return currentPeriod == productPeriod;
  }

  Widget _buildBillingToggle() {
    final isYearly = _selectedPeriod == SubscriptionPeriod.yearly;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Monthly'),
          selected: !isYearly,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedPeriod = SubscriptionPeriod.monthly;
                _selectedProductId = null;
              });
            }
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Yearly'),
              SizedBox(width: 6),
              Icon(
                Icons.local_fire_department_outlined,
                size: 16,
                color: Colors.orange,
              ),
            ],
          ),
          selected: isYearly,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedPeriod = SubscriptionPeriod.yearly;
                _selectedProductId = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCurrentSubscriptionSection() {
    if (_currentPlan == null) return const SizedBox.shrink();

    final periodText = _currentSubscriptionPeriod == 'yearly'
        ? 'Yearly'
        : 'Monthly';
    final planDisplayName = _currentPlan!.name == 'DeenHub Pro'
        ? 'Premium'
        : _currentPlan!.name;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '✨ Current Plan: $planDisplayName $periodText',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}