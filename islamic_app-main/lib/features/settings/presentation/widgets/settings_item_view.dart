import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';

class SettingsItemView extends StatelessWidget {
  final Routes? route;
  final String? title;
  final String? subtitle;
  final String? trailingText;
  final bool enabled;
  final EdgeInsetsDirectional? contentPadding;
  final dynamic icon;
  final Widget? trailing;
  final TextStyle? titleTextStyle;
  final void Function()? onTap;

  const SettingsItemView({
    super.key,
    this.route,
    this.title,
    this.subtitle,
    this.trailingText,
    this.enabled = true,
    this.contentPadding,
    this.icon,
    this.trailing,
    this.titleTextStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ListTile(
        contentPadding: contentPadding ?? px16,
        minVerticalPadding: 8,
        enabled: enabled,
        leading: (icon != null)
            ? ImageView(
                imagePath: icon,
                color: context.primaryColor.withValues(alpha: .5),
                height: 24,
                width: 24,
              )
            : null,
        trailing: trailing ??
            ((trailingText != null)
                ? Text(
                    trailingText!,
                    style: const TextStyle(color: ThemeColors.darkGray, fontSize: 14),
                  )
                : null),
        title: Text(
          (title ?? route?.path.capitalizeFirstLetter).orEmpty,
          style: titleTextStyle ??
              TextStyle(color: context.onSurfaceColor, fontSize: 16, fontWeight: FontWeight.normal),
          maxLines: 2,
        ),
        subtitle: (subtitle != null)
            ? Text(
                subtitle!,
                style: const TextStyle(color: ThemeColors.darkGray, fontSize: 14),
              ).withPadding(4.topPadding)
            : null,
        onTap: (onTap == null && route == null)
            ? null
            : () {
                if (onTap != null) {
                  onTap?.call();
                } else if (route != null) {
                  context.pushNamed(route?.name ?? '');
                }
              },
      ),
    );
  }
}
