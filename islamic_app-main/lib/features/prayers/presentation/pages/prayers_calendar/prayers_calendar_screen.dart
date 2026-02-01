import 'dart:collection';

import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/core/widgets/loading_view.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/location/presentation/bloc/location_bloc.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/hijri_date/calendar_type.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:deenhub/hijri_date/hijri_date_time.dart';

class PrayersCalendarScreen extends StatefulWidget {
  const PrayersCalendarScreen({super.key});

  @override
  State<PrayersCalendarScreen> createState() => _PrayersCalendarScreenState();
}

class _PrayersCalendarScreenState extends State<PrayersCalendarScreen> {
  final now = HijriDateTime.now(utc: true);
  PrayerLocationData? prayerLocationData;
  LocationData? locData;
  final prayerTypes = getMandatoryPrayersList();
  LinkedHashMap<HijriDateTime, List<PrayerItem>>? prayerTimes;

  @override
  void initState() {
    super.initState();
    prayerLocationData = getIt<SharedPrefsHelper>().prayerLocationData;
    locData = prayerLocationData?.toLocationData();
    initPrayerTimings();
  }

  void initPrayerTimings() {
    prayerTimes = getIt<LocationBloc>().getMonthlyPrayerTimings(
      CalendarType.gregorian,
      locData!,
      prayerLocationData!,
      prayerTypes,
      now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildLocationSuccessState();
  }

  Widget _buildLocationSuccessState() {
    return AppBarScaffold(
      pageTitle: locData!.locName,
      child: (prayerTimes == null || prayerTimes!.isEmpty)
          ? const LoadingView()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: context.primaryColor,
                  // color: context.tertiaryColor,
                  child: Column(
                    children: [
                      gapH16,
                      Text(
                        true
                            ? now.toDateTime().format(pattern: 'MMMM yyyy')
                            : now.toFormat(format: 'MMMM yyyy'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: context.onTertiaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      gapH16,
                      Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: _getColumnWidths(),
                        children: [
                          _buildHeaderView(),
                        ],
                      ),
                    ],
                  ).center(),
                ),
                _buildViewsContainer().expanded(),
              ],
            ),
    );
  }

  Widget _buildViewsContainer() {
    final list = prayerTimes!.entries
        .map((row) {
          return [
            _buildPrayerTimesItemView(row.key, row.value),
            _buildDividerRow(),
          ];
        })
        .flattened
        .toList();

    // list.insert(0, _buildHeaderView());

    return SingleChildScrollView(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: _getColumnWidths(),
        children: list,
      ),
    );
  }

  TableRow _buildPrayerTimesItemView(HijriDateTime date, List<PrayerItem> list) {
    final bgColor = Theme.of(context).colorScheme.surfaceDim;
    return TableRow(
      children: [
        Container(
          color: bgColor,
          // color: context.onSecondaryContainerColor,
          child: Text(
            true
                ? '${date.toDateTime().day}\n${date.hDay}/${date.hMonth}'
                : '${date.hDay}\n${date.toDateTime().day}/${date.toDateTime().month}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: DecorationStyles.getTextColor(bgColor),
              // color: context.onTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ).withPadding(py4),
        ),
        ...list.map(
          (e) => Text(
            e.time.timeWithoutPeriod(),
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: ThemeColors.darkGray,
            ),
          ).center(),
        ),
      ],
    );
  }

  TableRow _buildHeaderView() => TableRow(
        children: [
          const SizedBox.shrink(),
          ...prayerTypes.map(
            (e) => Text(
              e.label,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: context.onPrimaryColor,
                // color: context.onTertiaryColor,
              ),
            ).center().withPadding(py8),
          ),
        ],
      );

  TableRow _buildDividerRow() => const TableRow(
        children: [
          AppDivider(),
          AppDivider(),
          AppDivider(),
          AppDivider(),
          AppDivider(),
          AppDivider(),
        ],
      );

  Map<int, TableColumnWidth> _getColumnWidths() {
    return const {
      0: FlexColumnWidth(1.2),
      1: FlexColumnWidth(1),
      2: FlexColumnWidth(1),
      3: FlexColumnWidth(1),
      4: FlexColumnWidth(1),
      5: FlexColumnWidth(1),
    };
  }
}
