import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class CheckBoxListView<T> extends StatelessWidget {
  final List<T> list;
  final List<T> selectedValues;
  final List<T>? disabledValues;
  final String Function(T) getItemLabel;
  final String Function(T)? getItemSubtitle;
  final String? Function(int, T)? getItemSubtitle2;
  final void Function(bool?, T)? onChanged;

  const CheckBoxListView({
    super.key,
    required this.list,
    required this.selectedValues,
    this.disabledValues,
    required this.getItemLabel,
    this.getItemSubtitle,
    this.getItemSubtitle2,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      padding: py16,
      shrinkWrap: true,
      separatorBuilder: (context, index) => gapH8,
      itemBuilder: (context, index) {
        final item = list[index];
        final isEnabeld = !(disabledValues?.contains(item)).orFalse;

        return Material(
          type: MaterialType.transparency,
          child: CheckboxListTile.adaptive(
            value: selectedValues.contains(item),
            enabled: isEnabeld,
            title: Text(
              getItemLabel(item),
              style: TextStyle(
                fontSize: 16,
                color: isEnabeld ? context.onSurfaceColor : context.onSurfaceColor.withValues(alpha: .25),
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
            onChanged: (value) => onChanged?.call(value, item),
          ),
        );
      },
    );
  }
}
