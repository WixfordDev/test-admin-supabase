import 'package:deenhub/features/onboarding/presentation/widgets/divider_checked_list_view.dart';
import 'package:deenhub/features/settings/domain/models/checked_list/checked_list_tile_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/common/enums/prayer_calculation_method_type.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';

class CalculationMethodScreen extends StatefulWidget {
  final String method;

  const CalculationMethodScreen({super.key, required this.method});

  @override
  State<CalculationMethodScreen> createState() =>
      _CalculationMethodScreenState();
}

class _CalculationMethodScreenState extends State<CalculationMethodScreen> {
  late List<CheckedListTileItem> list;

  @override
  void initState() {
    super.initState();
    list = PrayerCalculationMethodType.values
        .map(
          (item) => CheckedListTileItem(
            value: item.name,
            title: item.label,
            subtitle: item.subtitle,
            description: item.description,
          ),
        )
        .toList();
    list.insert(
      0,
      CheckedListTileItem(
        value: PrayerCalculationMethodType.egyptian.name,
        title: LocaleKeys.methodAutoDetect.tr(),
        subtitle: PrayerCalculationMethodType.egyptian.label,
        description: PrayerCalculationMethodType.egyptian.subtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: context.tr(LocaleKeys.calcMethod),
      child: DividerCheckedListView(
        list: list,
        groupValue: widget.method,
        onTap: (value) {
          context.pop(value);
        },
      ),
    );
  }
}
