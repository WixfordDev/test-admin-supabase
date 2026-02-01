import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/common_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/core/widgets/list_view/radio_button_list_view.dart';

class RadioListDialog<T> extends StatelessWidget {
  final List<T> list;
  final T selectedValue;
  final String title;
  final String? closeText;
  final bool useFullScreen;
  final bool showRoundedBorder;
  final String Function(T) getItemLabel;
  final String? Function(T)? getItemSubtitle;
  final String? Function(int, T)? getItemSubtitle2;
  final void Function(T?)? onChanged;
  final Widget itemPadding;
  final List<Widget>? children;

  const RadioListDialog({
    super.key,
    required this.list,
    required this.selectedValue,
    required this.title,
    this.closeText,
    this.useFullScreen = false,
    this.showRoundedBorder = false,
    required this.getItemLabel,
    this.getItemSubtitle,
    this.getItemSubtitle2,
    this.onChanged,
    this.itemPadding = gapH8,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.onSurfaceColor,
          ),
        ).withPadding(p16),
        const AppDivider(),
        useFullScreen ? _buildListView(context).expanded() : _buildListView(context),
        if (children != null) ...children!,
        const AppDivider(),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(closeText ?? context.tr(LocaleKeys.close)),
          ),
        ).withPadding(8.endPadding),
      ],
    );
  }

  Widget _buildListView(BuildContext context) {
    return RadioButtonListView<T>(
      list: list,
      groupValue: selectedValue,
      getItemLabel: getItemLabel,
      getItemSubtitle: getItemSubtitle,
      getItemSubtitle2: getItemSubtitle2,
      showRoundedBorder: showRoundedBorder,
      itemPadding: itemPadding,
      onChanged: onChanged ??
          (value) {
            context.pop(value);
          },
    );
  }
}
