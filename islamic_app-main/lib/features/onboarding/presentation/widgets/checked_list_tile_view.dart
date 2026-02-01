import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:deenhub/features/settings/domain/models/checked_list/checked_list_tile_item.dart';

class CheckedListTileView extends StatelessWidget {
  final CheckedListTileItem item;
  final String? groupValue;
  final void Function(String?)? onTap;

  const CheckedListTileView({
    super.key,
    required this.item,
    this.groupValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellView(
      onTap: (onTap == null) ? null : (() => onTap!(item.value)),
      child: Row(
        children: [
          item.value == groupValue
              ? const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: ThemeColors.orange,
                  size: 32,
                )
              : const SizedBox(height: 32, width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  color: context.onSurfaceColor,
                ),
              ),
              if (item.subtitle != null || item.description != null) ...[
                if (item.subtitle != null)
                  Text(
                    item.subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.darkGray,
                    ),
                  ),
                if (item.description != null)
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColors.darkGray,
                    ),
                  ),
              ],
            ],
          ).expanded(),
        ],
      ).withPadding(p8),
    );
  }
}
