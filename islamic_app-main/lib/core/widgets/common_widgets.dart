import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';

class AppDivider extends StatelessWidget {
  final double height;
  final double thickness;

  const AppDivider({
    super.key,
    this.height = 1,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(height: height, thickness: thickness);
  }
}

class BottomSheetActionView extends StatelessWidget {
  final String textKey;
  final IconData icon;
  final void Function()? onTap;

  const BottomSheetActionView({
    super.key,
    required this.textKey,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellView(
      onTap: onTap,
      child: Row(
        children: [
          ImageView(
            imagePath: icon,
            color: context.onSecondaryContainerColor,
            padding: p16,
            backgroundShape: BoxShape.circle,
            backgroundColor: context.surfaceDimColor,
          ),
          gapW8,
          Text(
            context.tr(textKey),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: context.onSurfaceColor,
            ),
          ),
        ],
      ).withPadding(const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8)),
    );
  }
}
