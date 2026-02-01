import 'package:flutter/material.dart';

class SwitchView extends StatefulWidget {
  final void Function(bool) onChanged;
  final bool isDisabled;
  final WidgetStateProperty<Icon?>? thumbIcon;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;

  const SwitchView({
    super.key,
    this.isDisabled = false,
    required this.onChanged,
    this.thumbIcon,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
  });

  @override
  State<SwitchView> createState() => _SwitchViewState();
}

class _SwitchViewState extends State<SwitchView> {
  bool _isSwitchOn = false;

  @override
  Widget build(BuildContext context) {
    return SwitchStatelessView(
      value: _isSwitchOn,
      isDisabled: widget.isDisabled,
      thumbIcon: widget.thumbIcon,
      activeThumbColor: widget.activeThumbColor,
      inactiveThumbColor: widget.inactiveThumbColor,
      activeTrackColor: widget.activeTrackColor,
      inactiveTrackColor: widget.inactiveTrackColor,
      onChanged: (newValue) {
        widget.onChanged(newValue);
        setState(() {
          _isSwitchOn = newValue;
        });
      },
    );
  }
}

class SwitchStatelessView extends StatelessWidget {
  final bool value;
  final bool isDisabled;
  final void Function(bool) onChanged;
  final WidgetStateProperty<Icon?>? thumbIcon;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;

  const SwitchStatelessView({
    super.key,
    required this.value,
    this.isDisabled = false,
    required this.onChanged,
    this.thumbIcon,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: isDisabled ? null : onChanged,
      thumbIcon: thumbIcon,
      activeColor: activeThumbColor,
      inactiveThumbColor: inactiveThumbColor,
      activeTrackColor: activeTrackColor,
      inactiveTrackColor: inactiveTrackColor,
    );
  }
}
