import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/core/widgets/list_view/check_box_list_view.dart';

class CheckboxListDialog<T> extends StatefulWidget {
  final List<T> list;
  final List<T> selectedValues;
  final String title;
  final String? closeText;
  final bool useFullScreen;
  final String Function(T) getItemLabel;
  final String Function(T)? getItemSubtitle;
  final String? Function(int, T)? getItemSubtitle2;
  final void Function(bool?, T)? onChanged;
  final List<Widget>? children;

  const CheckboxListDialog({
    super.key,
    required this.list,
    required this.selectedValues,
    required this.title,
    this.closeText,
    this.useFullScreen = false,
    required this.getItemLabel,
    this.getItemSubtitle,
    this.getItemSubtitle2,
    this.onChanged,
    this.children,
  });

  @override
  State<CheckboxListDialog<T>> createState() => _CheckboxListDialogState<T>();
}

class _CheckboxListDialogState<T> extends State<CheckboxListDialog<T>> {
  late List<T> selectedValues;

  @override
  void initState() {
    super.initState();
    selectedValues = List.of(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.onSurfaceColor,
          ),
        ).withPadding(p16),
        const AppDivider(),
        widget.useFullScreen ? _buildListView(context).expanded() : _buildListView(context),
        if (widget.children != null) ...widget.children!,
        const AppDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(widget.closeText ?? context.tr(LocaleKeys.close)),
            ),
            TextButton(
              onPressed: () {
                context.pop(selectedValues);
              },
              child: Text(context.tr(LocaleKeys.save)),
            ),
          ],
        ).withPadding(px8),
      ],
    );
  }

  Widget _buildListView(BuildContext context) {
    return CheckBoxListView<T>(
      list: widget.list,
      selectedValues: selectedValues,
      getItemLabel: widget.getItemLabel,
      getItemSubtitle: widget.getItemSubtitle,
      getItemSubtitle2: widget.getItemSubtitle2,
      onChanged: widget.onChanged ??
          (value, item) {
            setState(() {
              if (value == true) {
                selectedValues.add(item);
              } else {
                selectedValues.remove(item);
              }
            });
          },
    );
  }
}
