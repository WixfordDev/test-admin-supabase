import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/core/widgets/global_media_player.dart';
import 'package:deenhub/features/main/domain/utils/navigation_bar_items.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/features/main/presentation/pages/more/more_bottom_sheet_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: DecorationStyles.appBarSystemUiOverlayStyle(
          appBarColor: context.primaryColor,
        ),
        toolbarHeight: 0,
      ),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Global media player above navigation
          const GlobalMediaPlayer(),
          const AppDivider(),
          NavigationBar(
            // indicatorColor: context.primaryColor.withValues(alpha: .25),
            elevation: 16,
            selectedIndex: widget.child.currentIndex,
            onDestinationSelected: (index) {
              if (index == NavigationBarItems.values.length - 1) {
                context.showBottomSheetNow(isScrollControlled: true, child: MoreBottomSheetScreen());
                return;
              }

              widget.child.goBranch(
                index,
                initialLocation: index == widget.child.currentIndex,
              );
              setState(() {});
            },
            destinations: NavigationBarItems.values.map((item) {
              return NavigationDestination(
                icon: ImageView(
                  imagePath: item.icon,
                  color: ThemeColors.darkGray,
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
