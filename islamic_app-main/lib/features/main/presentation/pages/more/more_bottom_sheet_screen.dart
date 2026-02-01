
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/features/main/domain/utils/more_item.dart';
import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'dart:async';
import 'package:deenhub/core/services/remote_config/app_remote_config_helper.dart';

class MoreBottomSheetScreen extends StatefulWidget {
  const MoreBottomSheetScreen({super.key});

  @override
  State<MoreBottomSheetScreen> createState() => _MoreBottomSheetScreenState();
}

class _MoreBottomSheetScreenState extends State<MoreBottomSheetScreen> {
  bool _isSubscribed = false;
  bool _isLoading = true;
  late AppRemoteConfigHelper _remoteConfig;

  // ADD: Subscriptions for real-time updates
  late StreamSubscription<bool> _purchaseStatusSubscription;
  late StreamSubscription<bool> _subscriptionStatusSubscription;

  final List<MoreItem> _baseItems = [
    MoreItem(
      route: Routes.qibla,
      title: LocaleKeys.qibla.tr(),
      icon: Assets.imagesIcKaaba,
      iconBgColor: ThemeColors.blue,
    ),
    MoreItem(
      route: Routes.hadith,
      title: "Hadith",
      icon: Icons.book_rounded,
      iconBgColor: const Color(0xFFc54949),
    ),
    MoreItem(
      route: Routes.zakat,
      title: "Zakat\nCalculator",
      icon: Icons.calculate_outlined,
      iconBgColor: const Color(0xFF43A047),
    ),
    MoreItem(
      route: Routes.aiChatbot,
      title: "AI\nDeenGuide",
      icon: Icons.chat_outlined,
      iconBgColor: const Color(0xFF5599c8),
    ),
    MoreItem(
      route: Routes.trivia,
      title: "Trivia",
      icon: Icons.lightbulb_outline,
      iconBgColor: const Color(0xFF3F51B5),
    ),
    MoreItem(
      route: Routes.duaCollection,
      title: "Dua\nCollection",
      icon: Icons.volunteer_activism_outlined,
      iconBgColor: const Color(0xFF9c27b0),
    ),
    MoreItem(
      route: Routes.prayerGuide,
      title: "Prayer\nGuide",
      icon: Icons.accessibility_new_rounded,
      iconBgColor: const Color(0xFFFF9800),
    ),
    MoreItem(
      route: Routes.hajjGuide,
      title: "Hajj\nGuide",
      icon: Icons.mosque_outlined,
      iconBgColor: const Color(0xFF8BC34A),
    ),
    MoreItem(
      route: Routes.wuduGuide,
      title: "Wudu\nGuide",
      icon: Icons.water_drop_outlined,
      iconBgColor: const Color(0xFF00BCD4),
    ),
    MoreItem(
      route: Routes.freeQuran,
      title: "Free\nQuran",
      icon: Icons.menu_book_outlined,
      iconBgColor: const Color(0xFF4CAF50),
    ),
    MoreItem(
      route: Routes.faq,
      title: "FAQ",
      icon: Icons.help_outline,
      iconBgColor: const Color(0xFF607D8B),
    ),
    MoreItem(
      route: Routes.settings,
      title: LocaleKeys.settings.tr(),
      icon: Icons.settings_outlined,
      iconBgColor: const Color(0xFFc77f59),
    ),
  ];

  final MoreItem _subscriptionItem = MoreItem(
    route: Routes.subscription,
    title: "Premium",
    icon: Icons.workspace_premium,
    iconBgColor: const Color(0xFFFFD700),
  );

  List<MoreItem> _items = [];

  @override
  void initState() {
    super.initState();
    _remoteConfig = getIt<AppRemoteConfigHelper>();
    _checkSubscription();

    final subscriptionService = getIt<SubscriptionService>();

    // Subscribe to purchase status changes
    _purchaseStatusSubscription =
        subscriptionService.purchaseStatusStream.listen((isSubscribed) {
          if (mounted) {
            setState(() {
              _isSubscribed = isSubscribed;
              _buildItemsList();
            });
          }
        });

    // ADD: Subscribe to subscription status changes
    _subscriptionStatusSubscription =
        subscriptionService.subscriptionStatusStream.listen((hasSubscription) {
          if (mounted) {
            _checkSubscription(); // Refresh subscription status
          }
        });
  }

  Future<void> _checkSubscription() async {
    final isSubscribed = await SubscriptionService.hasActiveSubscription();
    if (mounted) {
      setState(() {
        _isSubscribed = isSubscribed;
        _isLoading = false;
        _buildItemsList();
      });
    }
  }

  void _buildItemsList() {
    _items = [..._baseItems];

    if (!_remoteConfig.isTriviaEnabled) {
      _items.removeWhere((item) => item.route == Routes.trivia);
    }

    if (!_isSubscribed) {
      _items.insert(0, _subscriptionItem);
    }
  }

  @override
  void dispose() {
    _purchaseStatusSubscription.cancel();
    _subscriptionStatusSubscription.cancel(); // ADD
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) =>
          _buildMoreItemView(context, _items[index], index == 0 && !_isSubscribed),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
    );
  }

  Widget _buildMoreItemView(
      BuildContext context, MoreItem item, bool isSubscriptionItem) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ImageView(
              imagePath: item.icon,
              color: context.surfaceColor,
              backgroundShape: BoxShape.circle,
              backgroundColor: item.iconBgColor,
              padding: const EdgeInsetsDirectional.all(12),
              onTap: () {
                context.pop();
                context.pushNamed(item.route.name);
              },
            ),
            if (isSubscriptionItem)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Text(
                    "New",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            item.title ?? item.route.name.capitalizeFirstLetter,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSubscriptionItem ? FontWeight.bold : FontWeight.normal,
              color: isSubscriptionItem ? const Color(0xFFFFD700) : null,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}













// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:deenhub/config/gen/assets.gen.dart';
// import 'package:deenhub/config/gen/locale_keys.gen.dart';
// import 'package:deenhub/config/routes/routes.dart';
// import 'package:deenhub/config/themes/styles.dart';
// import 'package:deenhub/config/themes/theme_colors.dart';
// import 'package:deenhub/core/utils/primitive_utils.dart';
// import 'package:deenhub/core/utils/view_utils.dart';
// import 'package:deenhub/core/widgets/image_view.dart';
// import 'package:deenhub/features/main/domain/utils/more_item.dart';
// import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
// import 'package:deenhub/core/di/app_injections.dart';
// import 'dart:async';
// import 'package:deenhub/core/services/remote_config/app_remote_config_helper.dart';
//
// class MoreBottomSheetScreen extends StatefulWidget {
//   const MoreBottomSheetScreen({super.key});
//
//   @override
//   State createState() => _MoreBottomSheetScreenState();
// }
//
// class _MoreBottomSheetScreenState extends State {
//   bool _isSubscribed = false;
//   bool _isLoading = true;
//   late AppRemoteConfigHelper _remoteConfig;
//   late StreamSubscription<bool> _subscriptionStatusSubscription;
//
//   final List _baseItems = [
//     MoreItem(
//       route: Routes.qibla,
//       title: LocaleKeys.qibla.tr(),
//       icon: Assets.imagesIcKaaba,
//       iconBgColor: ThemeColors.blue,
//     ),
//     MoreItem(
//       route: Routes.hadith,
//       title: "Hadith",
//       icon: Icons.book_rounded,
//       iconBgColor: const Color(0xFFc54949),
//     ),
//     MoreItem(
//       route: Routes.zakat,
//       title: "Zakat\nCalculator",  // Add line break for long text
//       icon: Icons.calculate_outlined,
//       iconBgColor: const Color(0xFF43A047),
//     ),
//     MoreItem(
//       route: Routes.aiChatbot,
//       title: "AI\nDeenGuide",  // Add line break
//       icon: Icons.chat_outlined,
//       iconBgColor: const Color(0xFF5599c8),
//     ),
//     MoreItem(
//       route: Routes.trivia,
//       title: "Trivia",
//       icon: Icons.lightbulb_outline,
//       iconBgColor: const Color(0xFF3F51B5),
//     ),
//     MoreItem(
//       route: Routes.duaCollection,
//       title: "Dua\nCollection",  // Add line break
//       icon: Icons.volunteer_activism_outlined,
//       iconBgColor: const Color(0xFF9c27b0),
//     ),
//     MoreItem(
//       route: Routes.prayerGuide,
//       title: "Prayer\nGuide",  // Add line break
//       icon: Icons.accessibility_new_rounded,
//       iconBgColor: const Color(0xFFFF9800),
//     ),
//     MoreItem(
//       route: Routes.hajjGuide,
//       title: "Hajj\nGuide",  // Add line break
//       icon: Icons.mosque_outlined,
//       iconBgColor: const Color(0xFF8BC34A),
//     ),
//     MoreItem(
//       route: Routes.wuduGuide,
//       title: "Wudu\nGuide",  // Add line break
//       icon: Icons.water_drop_outlined,
//       iconBgColor: const Color(0xFF00BCD4),
//     ),
//     MoreItem(
//       route: Routes.freeQuran,
//       title: "Free\nQuran",  // Add line break
//       icon: Icons.menu_book_outlined,
//       iconBgColor: const Color(0xFF4CAF50),
//     ),
//     MoreItem(
//       route: Routes.faq,
//       title: "FAQ",
//       icon: Icons.help_outline,
//       iconBgColor: const Color(0xFF607D8B),
//     ),
//     MoreItem(
//       route: Routes.settings,
//       title: LocaleKeys.settings.tr(),
//       icon: Icons.settings_outlined,
//       iconBgColor: const Color(0xFFc77f59),
//     ),
//   ];
//
//   final MoreItem _subscriptionItem = MoreItem(
//     route: Routes.subscription,
//     title: "Premium",
//     icon: Icons.workspace_premium,
//     iconBgColor: const Color(0xFFFFD700),
//   );
//
//   List _items = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _remoteConfig = getIt();
//     _checkSubscription();
//
//     // Subscribe to subscription status changes
//     _subscriptionStatusSubscription =
//         getIt<SubscriptionService>().purchaseStatusStream.listen((isSubscribed) {
//       if (mounted) {
//         setState(() {
//           _isSubscribed = isSubscribed;
//           _buildItemsList();
//         });
//       }
//     });
//   }
//
//   Future _checkSubscription() async {
//     final isSubscribed = await SubscriptionService.hasActiveSubscription();
//     setState(() {
//       _isSubscribed = isSubscribed;
//       _isLoading = false;
//       _buildItemsList();
//     });
//   }
//
//   void _buildItemsList() {
//     _items = [..._baseItems];
//
//     if (!_remoteConfig.isTriviaEnabled) {
//       _items.removeWhere((item) => item.route == Routes.trivia);
//     }
//
//     if (!_isSubscribed) {
//       _items.insert(0, _subscriptionItem);
//     }
//   }
//
//   @override
//   void dispose() {
//     _subscriptionStatusSubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         childAspectRatio: 0.75,  // Changed from .6 to .75 for more height
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 16,  // Increased from 8 to 16
//       ),
//       itemCount: _items.length,
//       itemBuilder: (context, index) =>
//           _buildMoreItemView(context, _items[index], index == 0 && !_isSubscribed),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(12),  // Reduced padding
//     );
//   }
//
//   Widget _buildMoreItemView(
//       BuildContext context, MoreItem item, bool isSubscriptionItem) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,  // Important: use minimum space
//       children: [
//         Stack(
//           clipBehavior: Clip.none,  // Allow badge to overflow slightly
//           children: [
//             ImageView(
//               imagePath: item.icon,
//               color: context.surfaceColor,
//               backgroundShape: BoxShape.circle,
//               backgroundColor: item.iconBgColor,
//               padding: const EdgeInsetsDirectional.all(12),
//               onTap: () {
//                 context.pop();
//                 context.pushNamed(item.route.name);
//               },
//             ),
//             if (isSubscriptionItem)
//               Positioned(
//                 right: -2,
//                 top: -2,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.white, width: 1.5),
//                   ),
//                   child: const Text(
//                     "New",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),  // Fixed spacing
//         Flexible(  // Wrap Text in Flexible
//           child: Text(
//             item.title ?? item.route.name.capitalizeFirstLetter,
//             textAlign: TextAlign.center,
//             maxLines: 2,  // Allow max 2 lines
//             overflow: TextOverflow.ellipsis,  // Add ellipsis if still too long
//             style: TextStyle(
//               fontSize: 11,  // Slightly smaller font
//               fontWeight: isSubscriptionItem ? FontWeight.bold : FontWeight.normal,
//               color: isSubscriptionItem ? const Color(0xFFFFD700) : null,
//               height: 1.2,  // Tighter line height
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:deenhub/config/gen/assets.gen.dart';
// // import 'package:deenhub/config/gen/locale_keys.gen.dart';
// // import 'package:deenhub/config/routes/routes.dart';
// // import 'package:deenhub/config/themes/styles.dart';
// // import 'package:deenhub/config/themes/theme_colors.dart';
// // import 'package:deenhub/core/utils/primitive_utils.dart';
// // import 'package:deenhub/core/utils/view_utils.dart';
// // import 'package:deenhub/core/widgets/image_view.dart';
// // import 'package:deenhub/features/main/domain/utils/more_item.dart';
// // import 'package:deenhub/features/subscription/data/services/subscription_service.dart';
// // import 'package:deenhub/core/di/app_injections.dart';
// // import 'package:deenhub/core/services/remote_config/app_remote_config_helper.dart';
// //
// // class MoreBottomSheetScreen extends StatefulWidget {
// //   const MoreBottomSheetScreen({super.key});
// //
// //   @override
// //   State<MoreBottomSheetScreen> createState() => _MoreBottomSheetScreenState();
// // }
// //
// // class _MoreBottomSheetScreenState extends State<MoreBottomSheetScreen> {
// //   bool _isSubscribed = false;
// //   bool _isLoading = true;
// //   late AppRemoteConfigHelper _remoteConfig;
// //
// //   final List<MoreItem> _baseItems = [
// //     MoreItem(
// //       route: Routes.qibla,
// //       title: LocaleKeys.qibla.tr(),
// //       icon: Assets.imagesIcKaaba,
// //       iconBgColor: ThemeColors.blue,
// //     ),
// //     MoreItem(
// //       route: Routes.hadith,
// //       title: "Hadith",
// //       icon: Icons.book_rounded,
// //       iconBgColor: const Color(0xFFc54949),
// //     ),
// //     MoreItem(
// //       route: Routes.zakat,
// //       title: "Zakat Calculator",
// //       icon: Icons.calculate_outlined,
// //       iconBgColor: const Color(0xFF43A047),
// //     ),
// //     MoreItem(
// //       route: Routes.aiChatbot,
// //       title: "AI DeenGuide",
// //       icon: Icons.chat_outlined,
// //       iconBgColor: const Color(0xFF5599c8),
// //     ),
// //     // Show Trivia as the 5th option
// //     MoreItem(
// //       route: Routes.trivia,
// //       title: "Trivia",
// //       icon: Icons.lightbulb_outline,
// //       iconBgColor: const Color(0xFF3F51B5),
// //     ),
// //     MoreItem(
// //       route: Routes.duaCollection,
// //       title: "Dua Collection",
// //       icon: Icons.volunteer_activism_outlined,
// //       iconBgColor: const Color(0xFF9c27b0),
// //     ),
// //     MoreItem(
// //       route: Routes.prayerGuide,
// //       title: "Prayer Guide",
// //       icon: Icons.accessibility_new_rounded,
// //       iconBgColor: const Color(0xFFFF9800),
// //     ),
// //     MoreItem(
// //       route: Routes.hajjGuide,
// //       title: "Hajj Guide",
// //       icon: Icons.mosque_outlined,
// //       iconBgColor: const Color(0xFF8BC34A),
// //     ),
// //     MoreItem(
// //       route: Routes.wuduGuide,
// //       title: "Wudu Guide",
// //       icon: Icons.water_drop_outlined,
// //       iconBgColor: const Color(0xFF00BCD4),
// //     ),
// //     MoreItem(
// //       route: Routes.freeQuran,
// //       title: "Free Quran",
// //       icon: Icons.menu_book_outlined,
// //       iconBgColor: const Color(0xFF4CAF50),
// //     ),
// //     MoreItem(
// //       route: Routes.faq,
// //       title: "FAQ",
// //       icon: Icons.help_outline,
// //       iconBgColor: const Color(0xFF607D8B),
// //     ),
// //     MoreItem(
// //       route: Routes.settings,
// //       title: LocaleKeys.settings.tr(),
// //       icon: Icons.settings_outlined,
// //       iconBgColor: const Color(0xFFc77f59),
// //     ),
// //   ];
// //
// //   final MoreItem _subscriptionItem = MoreItem(
// //     route: Routes.subscription,
// //     title: "Premium",
// //     icon: Icons.workspace_premium,
// //     iconBgColor: const Color(0xFFFFD700),
// //   );
// //
// //   List<MoreItem> _items = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _remoteConfig = getIt<AppRemoteConfigHelper>();
// //     _checkSubscription();
// //   }
// //
// //   Future<void> _checkSubscription() async {
// //     final isSubscribed = await SubscriptionService.hasActiveSubscription();
// //
// //     setState(() {
// //       _isSubscribed = isSubscribed;
// //       _isLoading = false;
// //       _buildItemsList();
// //     });
// //   }
// //
// //   void _buildItemsList() {
// //     _items = [..._baseItems];
// //
// //     // Remove trivia if feature is disabled via remote config
// //     if (!_remoteConfig.isTriviaEnabled) {
// //       _items.removeWhere((item) => item.route == Routes.trivia);
// //     }
// //
// //     if (!_isSubscribed) {
// //       // Insert subscription option as the first item
// //       _items.insert(0, _subscriptionItem);
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading) {
// //       return const Center(
// //         child: CircularProgressIndicator(),
// //       );
// //     }
// //
// //     return GridView.builder(
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 4,
// //         childAspectRatio: .6,
// //         crossAxisSpacing: 8,
// //         mainAxisSpacing: 8,
// //       ),
// //       itemCount: _items.length,
// //       itemBuilder: (context, index) => _buildMoreItemView(context, _items[index], index == 0 && !_isSubscribed),
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       padding: p16,
// //     );
// //   }
// //
// //   Widget _buildMoreItemView(BuildContext context, MoreItem item, bool isSubscriptionItem) {
// //     return Column(
// //       children: [
// //         gapH16,
// //         Stack(
// //           children: [
// //             ImageView(
// //               imagePath: item.icon,
// //               color: context.surfaceColor,
// //               backgroundShape: BoxShape.circle,
// //               backgroundColor: item.iconBgColor,
// //               padding: p16,
// //               onTap: () {
// //                 context.pop();
// //                 context.pushNamed(item.route.name);
// //               },
// //             ),
// //             if (isSubscriptionItem)
// //               Positioned(
// //                 right: 0,
// //                 top: 0,
// //                 child: Container(
// //                   padding: const EdgeInsets.all(4),
// //                   decoration: BoxDecoration(
// //                     color: Colors.red,
// //                     shape: BoxShape.circle,
// //                     border: Border.all(color: Colors.white, width: 1.5),
// //                   ),
// //                   child: const Text(
// //                     "New",
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 8,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         gapH16,
// //         Text(
// //           item.title ?? item.route.name.capitalizeFirstLetter,
// //           textAlign: TextAlign.center,
// //           style: isSubscriptionItem
// //             ? const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700))
// //             : null,
// //         ),
// //       ],
// //     );
// //   }
// // }
