import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class TextListView<T> extends StatelessWidget {
  final List<T> list;
  final bool showRoundedBorder;
  final Widget itemPadding;
  final String Function(T) getItemLabel;
  final String Function(T)? getItemSubtitle;
  final String? Function(int, T)? getItemSubtitle2;
  final void Function(T?)? onTap;

  const TextListView({
    super.key,
    required this.list,
    required this.getItemLabel,
    this.getItemSubtitle,
    this.getItemSubtitle2,
    this.showRoundedBorder = true,
    this.itemPadding = gapH8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      padding: py16,
      shrinkWrap: true,
      separatorBuilder: (context, index) => itemPadding,
      itemBuilder: (context, index) {
        final item = list[index];
        return Material(
          type: MaterialType.transparency,
          child: ListTile(
            title: Text(
              getItemLabel(item),
              style: TextStyle(
                fontSize: 16,
                color: context.onSurfaceColor,
              ),
            ),
            subtitle: (getItemSubtitle == null && getItemSubtitle2 == null)
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (getItemSubtitle != null)
                        Text(
                          getItemSubtitle!(item),
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeColors.darkGray,
                          ),
                        ),
                      if (getItemSubtitle2?.call(index, item) != null)
                        Text(
                          getItemSubtitle2!(index, item)!,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.onSurfaceColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
            visualDensity: VisualDensity.compact,
            shape: showRoundedBorder
                ? 48.roundedBorder(
                    side: BorderSide(
                      color: context.primaryColor.withValues(alpha: .3),
                      width: 2,
                    ),
                  )
                : null,
            onTap: onTap != null
                ? () {
                    onTap!(item);
                  }
                : null,
          ),
        );
      },
    );
  }
}
