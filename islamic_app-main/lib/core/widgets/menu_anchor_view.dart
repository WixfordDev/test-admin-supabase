import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';

class MenuAnchorView extends StatelessWidget {
  final Offset alignmentOffset;
  final ShapeBorder? shapeBorder;
  final List<Widget> menuChildren;
  final Widget child;

  const MenuAnchorView({
    super.key,
    this.shapeBorder,
    this.alignmentOffset = Offset.zero,
    required this.menuChildren,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(shape: WidgetStatePropertyAll(12.roundedBorder())),
      alignmentOffset: alignmentOffset,
      menuChildren: menuChildren,
      builder: (context, controller, child) {
        return InkWellView(
          shapeBorder: shapeBorder,
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: child!,
        );
      },
      child: child,
    );
  }
}

MenuItemButton getMenuItemView(
  BuildContext context, {
  String? label,
  required String title,
  String? subtitle,
  void Function()? onPressed,
}) =>
    MenuItemButton(
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: context.primaryColor,
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 15,
              color: context.onSurfaceColor,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: ThemeColors.darkGray,
              ),
            ),
        ],
      ).withPadding(py8),
    );
