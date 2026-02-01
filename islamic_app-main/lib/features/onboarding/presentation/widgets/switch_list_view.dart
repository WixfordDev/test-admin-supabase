import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class SwitchListView<T> extends StatelessWidget {
  final Map<T, bool> list;
  final String Function(T) getItemLabel;
  final void Function(T, bool) onChanged;

  const SwitchListView({
    super.key,
    required this.list,
    required this.getItemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: py16,
      separatorBuilder: (context, index) => gapH8,
      itemBuilder: (context, index) {
        final item = list.keys.elementAt(index);
        return SwitchListTile.adaptive(
          value: list.values.elementAt(index),
          title: Text(getItemLabel(item)),
          visualDensity: VisualDensity.compact,
          shape: 48.roundedBorder(
            side: BorderSide(
              color: context.primaryColor.withValues(alpha: .3),
              width: 2,
            ),
          ),
          onChanged: (value) {
            onChanged.call(item, value);
          },
        );
      },
    );
  }
}
