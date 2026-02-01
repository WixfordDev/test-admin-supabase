import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/loading_view.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/checked_list_tile_view.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/divider_checked_list_view.dart';
import 'package:deenhub/features/settings/domain/models/checked_list/checked_list_tile_item.dart';
import 'package:timezone/timezone.dart' as tz;

class SelectTimezoneScreen extends StatefulWidget {
  static const argZone = 'zone';
  static const argDeviceTimezone = 'deviceTimezone';

  final Map<String, String> queryParams;

  const SelectTimezoneScreen({super.key, required this.queryParams});

  @override
  State<SelectTimezoneScreen> createState() => _SelectTimezoneScreenState();
}

class _SelectTimezoneScreenState extends State<SelectTimezoneScreen> {
  late String? zone;
  late CheckedListTileItem deviceTime;
  List<CheckedListTileItem> list = [];

  @override
  void initState() {
    super.initState();
    // Selected Time
    zone = widget.queryParams[SelectTimezoneScreen.argZone];
    // Device time
    final deviceTimezone = widget.queryParams[SelectTimezoneScreen.argDeviceTimezone]!;

    final deviceLoc = tz.getLocation(deviceTimezone);
    deviceTime = CheckedListTileItem(
      value: deviceTimezone,
      title: LocaleKeys.deviceTimeZone.tr(),
      subtitle: deviceLoc.offsetGMT,
    );

    loadData();
  }

  Future<void> loadData() async {
    Future.delayed(Duration.zero, () {
      final locations = tz.timeZoneDatabase.locations.values.toList();
      locations.sort((a, b) => a.currentTimeZone.offset.compareTo(b.currentTimeZone.offset));
      return locations
          .map(
            (item) => CheckedListTileItem(
              value: item.name,
              title: item.name,
              subtitle: item.offsetGMT,
            ),
          )
          .toList();
    }).then((value) {
      setState(() {
        list = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      pageTitle: context.tr(LocaleKeys.selectTimeZone),
      useScrollView: false,
      children: [
        CheckedListTileView(
          item: deviceTime,
          groupValue: zone,
          onTap: (value) {
            context.pop(value);
          },
        ),
        list.isEmpty
            ? const LoadingView()
            : DividerCheckedListView(
                list: list,
                groupValue: zone,
                showScrollbar: true,
                shrinkWrap: true,
                onTap: (value) {
                  context.pop(value);
                },
              ).expanded(),
      ],
    );
  }
}
