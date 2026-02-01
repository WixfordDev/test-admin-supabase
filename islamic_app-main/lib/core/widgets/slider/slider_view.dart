import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class SliderView extends StatelessWidget {
  final double min;
  final double max;
  final int? divisions;
  final double value;
  final void Function(double) onChanged;

  const SliderView({
    super.key,
    required this.min,
    required this.max,
    this.divisions,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 10.0,
        activeTickMarkColor: context.onSurfaceColor,
        inactiveTickMarkColor: context.onSurfaceColor,
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
        activeTrackColor: context.onSurfaceColor,
        inactiveTrackColor: context.onSurfaceColor.withValues(alpha: .2),
        valueIndicatorColor: context.onSurfaceColor,
        thumbColor: context.onSurfaceColor,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
        ),
      ),
      child: Slider.adaptive(
        min: min,
        max: max,
        value: value,
        divisions: divisions,
        label: value.round().toString(),
        onChanged: onChanged,
      ),
    );
  }
}
