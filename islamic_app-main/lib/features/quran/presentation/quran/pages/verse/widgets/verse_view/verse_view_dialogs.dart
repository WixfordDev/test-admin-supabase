import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiSubscriptionRequiredDialog extends StatelessWidget {
  const AiSubscriptionRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.workspace_premium, color: context.primaryColor),
          const SizedBox(width: 8),
          const Text('DeenHub Pro'),
        ],
      ),
      content: const Text(
        'AI explanation is available exclusively for DeenHub Pro subscribers. Upgrade to access this premium feature.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.pushNamed(Routes.subscription.name);
          },
          child: const Text('Upgrade Now'),
        ),
      ],
    );
  }
}

class SubscriptionRequiredDialog extends StatelessWidget {
  const SubscriptionRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.workspace_premium, color: context.primaryColor),
          const SizedBox(width: 8),
          const Text('Subscription Required').expanded(),
        ],
      ),
      content: const Text(
        'The memorization feature requires an active subscription. Get Barakah Access for free or upgrade to other plans.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.pushNamed(Routes.subscription.name);
          },
          child: const Text('View Subscription Plans'),
        ),
      ],
    );
  }
}

class LoginRequiredDialog extends StatelessWidget {
  final String feature;

  const LoginRequiredDialog({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: context.primaryColor),
          const SizedBox(width: 8),
          const Text('Login Required'),
        ],
      ),
      content: Text(
        'You need to log in to use the $feature feature. This allows us to save your progress and provide personalized content.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.pushNamed(Routes.login.name);
          },
          child: const Text('Login Now'),
        ),
      ],
    );
  }
}

class SubscriptionRequiredView extends StatelessWidget {
  const SubscriptionRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Subscription Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The memorization feature requires an active subscription. Get Barakah Access for free or upgrade to other plans.',
            style: TextStyle(color: Colors.orange.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed(Routes.subscription.name),
            icon: const Icon(Icons.card_membership),
            label: const Text('View Subscription Plans'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade500,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyLimitExceededDialog extends StatelessWidget {
  const MonthlyLimitExceededDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Monthly Limit Exceeded'),
      content: const Text(
        'You have exceeded your monthly token limit. Please wait until next month to continue using the AI Explanation feature.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
