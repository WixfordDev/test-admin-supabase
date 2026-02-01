import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/text_styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/main.dart';

class DropdownView<T> extends StatefulWidget {
  const DropdownView({
    super.key,
    required this.dropdownItems,
    this.preSelectedValue,
    this.width,
    this.label,
    this.showSubtitle = false,
    this.isDense = true,
    this.prefixLabel,
    this.prefixIcon,
    required this.onChanged,
    required this.getItemLabel,
    this.getItemDesc,
  });
  final List<T> dropdownItems;
  final String? preSelectedValue;
  final double? width;
  final String? label;
  final bool showSubtitle;
  final bool isDense;
  final String? prefixLabel;
  final dynamic prefixIcon;
  final void Function(T?) onChanged;
  final String Function(T) getItemLabel;
  final String Function(T)? getItemDesc;

  @override
  State<DropdownView> createState() => _DropdownViewState();
}

class _DropdownViewState extends State<DropdownView> {
  late ValueNotifier<String?> _valueListenable;

  @override
  void initState() {
    _valueListenable = ValueNotifier<String?>(widget.preSelectedValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownStatelessView(
      dropdownItems: widget.dropdownItems,
      valueListenable: _valueListenable,
      width: widget.width,
      label: widget.label,
      showSubtitle: widget.showSubtitle,
      isDense: widget.isDense,
      prefixLabel: widget.prefixLabel,
      prefixIcon: widget.prefixIcon,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {
          _valueListenable.value = value;
        });
      },
      getItemLabel: widget.getItemLabel,
      getItemDesc: widget.getItemDesc,
    );
  }
}

class DropdownStatelessView<T> extends StatelessWidget {
  const DropdownStatelessView({
    super.key,
    required this.dropdownItems,
    this.valueListenable,
    this.width,
    this.label,
    this.showCenter = false,
    this.showSubtitle = false,
    this.isDense = true,
    this.isOutlineBorder = true,
    this.prefixLabel,
    this.prefixIcon,
    required this.onChanged,
    required this.getItemLabel,
    this.getItemDesc,
  });
  final List<T> dropdownItems;
  final ValueNotifier<T?>? valueListenable;
  final double? width;
  final String? label;
  final bool showCenter;
  final bool showSubtitle;
  final bool isDense;
  final bool isOutlineBorder;
  final String? prefixLabel;
  final dynamic prefixIcon;
  final void Function(T?) onChanged;
  final String Function(T) getItemLabel;
  final String Function(T)? getItemDesc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _buildDropDown(context),
    );
  }

  Widget _buildDropDown(BuildContext context) {
    return DropdownButtonFormField2<T>(
      items: dropdownItems
          .map(
            (e) => DropdownItem<T>(
              value: e,
              intrinsicHeight: showSubtitle,
              child: getItemDesc != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getItemLabel(e),
                          style: TextStyle(color: context.onSurfaceColor, fontSize: 16),
                        ),
                        Text(
                          getItemDesc!(e),
                          style: const TextStyle(color: ThemeColors.darkGray, fontSize: 12),
                        ),
                      ],
                    ).withPadding(py4)
                  : Text(
                      getItemLabel(e),
                      maxLines: 4,
                      style: TextStyles.dropDownTextStyle(context),
                    ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => dropdownItems
          .map(
            (e) => DropdownItem<T>(
              value: e,
              child: showCenter
                  ? Text(
                      getItemLabel(e),
                      style: TextStyles.dropDownTextStyle(context),
                    ).center()
                  : Text(
                      getItemLabel(e),
                      style: TextStyles.dropDownTextStyle(context),
                    ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsetsDirectional.symmetric(vertical: 0, horizontal: 16),
        border: isOutlineBorder
            ? DecorationStyles.editTextBorder
            : DecorationStyles.editTextUnderlineBorder,
        filled: !isOutlineBorder,
        fillColor: context.surfaceContainerColor,
        // fillColor: context.onSecondaryContainerColor,
        isDense: isDense,
        labelText: label,
        labelStyle: TextStyles.labelTextStyle,
        prefixText: prefixLabel,
        prefixStyle: TextStyles.labelTextStyle,
        prefixIcon: (prefixIcon != null)
            ? ImageView(
                imagePath: prefixIcon!,
                color: ThemeColors.lightTeal,
              )
            : null,
      ),
      valueListenable: valueListenable,
      onChanged: (value) {
        if (valueListenable?.value == value) {
          return;
        }

        logger.d('Dropdown Selcted: $value');
        onChanged(value);
      },
      buttonStyleData: FormFieldButtonStyleData(
        width: width ?? 80,
      ),
      style: TextStyles.dropDownTextStyle(context),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down_rounded),
        openMenuIcon: Icon(Icons.keyboard_arrow_up_rounded),
        iconEnabledColor: ThemeColors.darkBlue,
        iconSize: 16,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        maxHeight: context.height / 2,
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
      isDense: false,
      isExpanded: true,
    );
  }
}
