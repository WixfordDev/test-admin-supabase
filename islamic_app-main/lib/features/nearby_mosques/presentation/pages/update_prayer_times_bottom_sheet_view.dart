import 'package:deenhub/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/button/outlined_button_view.dart';
import 'package:deenhub/features/location/data/entity/location_data.dart';
import 'package:deenhub/features/nearby_mosques/data/repositories/mosque_notification_repository.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';

class UpdatePrayerTimesBottomSheetView extends StatefulWidget {
  final LocationData locData;
  final String? mosqueId;
  final String? mosqueName;
  final double? mosqueLatitude;
  final double? mosqueLongitude;

  const UpdatePrayerTimesBottomSheetView({
    super.key,
    required this.locData,
    this.mosqueId,
    this.mosqueName,
    this.mosqueLatitude,
    this.mosqueLongitude,
  });

  @override
  State<UpdatePrayerTimesBottomSheetView> createState() =>
      _UpdatePrayerTimesBottomSheetViewState();
}

class _UpdatePrayerTimesBottomSheetViewState
    extends State<UpdatePrayerTimesBottomSheetView> {
  late List<PrayerItem>? prayerTimes;
  late List<PrayerItem>? originalPrayerTimes;
  late List<int> adjustments;
  bool _isCurrentlyEditing = false;
  bool _isSaving = false;

  final Map<int, Map<String, bool>> _modifiedPrayerTimes = {};
  bool _wasReset = false;
  bool _isUpdatingFromOffset = false;

  final Map<String, Map<String, Map<String, TextEditingController>>>
  _prayerTimeControllers = {};
  final Map<String, Map<String, bool>> _prayerTimeIsPm = {};
  final Map<String, TextEditingController> _iqamahOffsetControllers = {};
  final Map<String, FocusNode> _iqamahOffsetFocusNodes = {};
  final FocusNode _saveButtonFocusNode = FocusNode();
  final Map<String, Map<String, Map<String, FocusNode>>> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    prayerTimes = widget.locData.prayerTimes
        ?.map((prayer) => prayer.copyWith())
        .toList();
    _calculateOriginalPrayerTimes();
    adjustments = List<int>.from(widget.locData.adjustments);
    _initControllers();
  }

  void _calculateOriginalPrayerTimes() {
    if (widget.locData.prayerTimes == null) {
      originalPrayerTimes = null;
      return;
    }

    try {
      final prayerLocData = PrayerLocationData(
        lat: widget.locData.lat,
        lng: widget.locData.lng,
        locName: widget.locData.locName,
        timezone: widget.locData.timezone,
        country: '',
        calculationMethod: widget.locData.calculationMethod,
        asrMethod: widget.locData.asrMethod,
      );

      final originalLocData = widget.locData.copyWith(
        adjustments: List<int>.filled(widget.locData.adjustments.length, 0),
      );

      final originalData = PrayerTimesHelper.getPrayerTimings(
        originalLocData,
        prayerLocData,
        time: widget.locData.currentTime,
      );

      originalPrayerTimes = originalData.prayerTimes
          ?.map((prayer) => prayer.copyWith())
          .toList();
    } catch (e) {
      logger.e('Error calculating original prayer times: $e');
      originalPrayerTimes = widget.locData.prayerTimes
          ?.map((prayer) => prayer.copyWith())
          .toList();
    }
  }

  void _initControllers() {
    if (prayerTimes == null || prayerTimes!.isEmpty) return;
    prayerTimes!.removeWhere((e) => e.type == PrayerType.sunrise);
    originalPrayerTimes!.removeWhere((e) => e.type == PrayerType.sunrise);

    for (var prayer in prayerTimes!) {
      DateTime iqamahTime = prayer.iqamahTime;
      if (iqamahTime == prayer.time) {
        iqamahTime = prayer.time.add(Duration(minutes: 15));
        final index = prayerTimes!.indexOf(prayer);
        prayerTimes![index] = prayer.copyWith(iqamahTime: iqamahTime);
      }

      final bool isPmAdhan = prayer.time.hour >= 12;
      final int adhanHour12 = prayer.time.hour > 12
          ? prayer.time.hour - 12
          : (prayer.time.hour == 0 ? 12 : prayer.time.hour);

      final bool isPmIqamah = iqamahTime.hour >= 12;
      final int iqamahHour12 = iqamahTime.hour > 12
          ? iqamahTime.hour - 12
          : (iqamahTime.hour == 0 ? 12 : iqamahTime.hour);

      final String adhanHour = adhanHour12.toString().padLeft(2, '0');
      final String adhanMinute = prayer.time.minute.toString().padLeft(2, '0');
      final String iqamahHour = iqamahHour12.toString().padLeft(2, '0');
      final String iqamahMinute = iqamahTime.minute.toString().padLeft(2, '0');

      _prayerTimeControllers[prayer.type.label] = {
        'adhan': {
          'hour': TextEditingController(text: adhanHour),
          'minute': TextEditingController(text: adhanMinute),
        },
        'iqamah': {
          'hour': TextEditingController(text: iqamahHour),
          'minute': TextEditingController(text: iqamahMinute),
        },
      };

      _focusNodes[prayer.type.label] = {
        'adhan': {'hour': FocusNode(), 'minute': FocusNode()},
        'iqamah': {'hour': FocusNode(), 'minute': FocusNode()},
      };

      _prayerTimeIsPm[prayer.type.label] = {
        'adhan': isPmAdhan,
        'iqamah': isPmIqamah,
      };

      final adhanTimeOfDay = Duration(
        hours: prayer.time.hour,
        minutes: prayer.time.minute,
      );
      final iqamahTimeOfDay = Duration(
        hours: iqamahTime.hour,
        minutes: iqamahTime.minute,
      );
      final offsetMinutes =
          iqamahTimeOfDay.inMinutes - adhanTimeOfDay.inMinutes;

      _iqamahOffsetControllers[prayer.type.label] = TextEditingController(
        text: offsetMinutes.toString(),
      );
      _iqamahOffsetFocusNodes[prayer.type.label] = FocusNode();
    }
  }

  @override
  void dispose() {
    _prayerTimeControllers.forEach((prayer, types) {
      types.forEach((type, controllers) {
        controllers.forEach((field, controller) {
          controller.dispose();
        });
      });
    });

    _focusNodes.forEach((prayer, types) {
      types.forEach((type, nodes) {
        nodes.forEach((field, node) {
          node.dispose();
        });
      });
    });

    _iqamahOffsetControllers.forEach((key, controller) {
      controller.dispose();
    });
    _iqamahOffsetFocusNodes.forEach((key, node) {
      node.dispose();
    });

    _saveButtonFocusNode.dispose();
    super.dispose();
  }

  // Validation: Check if adhan time is before iqamah time
  bool _isAdhanBeforeIqamah(int index) {
    if (prayerTimes == null || index >= prayerTimes!.length) return true;

    final adhanTime = prayerTimes![index].time;
    final iqamahTime = prayerTimes![index].iqamahTime;

    final adhanMinutes = adhanTime.hour * 60 + adhanTime.minute;
    final iqamahMinutes = iqamahTime.hour * 60 + iqamahTime.minute;

    return adhanMinutes < iqamahMinutes;
  }

  // Show validation error message
  void _showValidationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return KeyboardActions(
          config: _buildKeyboardActionsConfig(context),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UpdatePrayerTimesHeader(
                  onReset: () {
                    if (originalPrayerTimes != null) {
                      setState(() {
                        prayerTimes = originalPrayerTimes!
                            .map((prayer) => prayer.copyWith())
                            .toList();
                        _modifiedPrayerTimes.clear();
                        adjustments = List<int>.filled(prayerTimes!.length, 0);
                        _wasReset = true;
                        _initControllers();
                      });
                    }
                  },
                ),
                gapH4,
                _PrayerTimesTable(
                  prayerTimes: prayerTimes,
                  prayerTimeControllers: _prayerTimeControllers,
                  prayerTimeIsPm: _prayerTimeIsPm,
                  focusNodes: _focusNodes,
                  iqamahOffsetControllers: _iqamahOffsetControllers,
                  iqamahOffsetFocusNodes: _iqamahOffsetFocusNodes,
                  onTimeChanged: (index, hourText, minuteText, isAdhan) {
                    _wasReset = false;
                    _updatePrayerTime(
                      index,
                      hourText,
                      minuteText,
                      isAdhan: isAdhan,
                    );
                  },
                  onAmPmToggled: (prayerName, timeType, isPm) {
                    _wasReset = false;
                    _prayerTimeIsPm[prayerName]?[timeType] = !isPm;
                    setState(() {});
                  },
                  onOffsetChanged: (index, offsetText) {
                    _wasReset = false;
                    _updateOffset(index, offsetText);
                  },
                  onFieldEditingComplete: (prayerIndex, isAdhan) async {
                    setState(() {
                      _isCurrentlyEditing = false;
                    });

                    FocusScope.of(context).unfocus();

                    // Validate before saving
                    if (!_isAdhanBeforeIqamah(prayerIndex)) {
                      _showValidationError(
                        "Adhan time must be before Iqamah time",
                      );
                      return;
                    }

                    if (mounted && !_isSaving) {
                      await _saveUpdatedTimes();

                      if (mounted) {
                        context.pop({
                          'adjustments': adjustments,
                          'updatedPrayerTimes': prayerTimes,
                        });
                      }
                    }
                  },
                  modifiedPrayerTimes: _modifiedPrayerTimes,
                  isCurrentlyEditing: _isCurrentlyEditing,
                  onEditingStateChanged: (isEditing) {
                    _isCurrentlyEditing = isEditing;
                  },
                  onTimeUpdate: () => _updateTimeFromControllers(),
                ),
                gapH4,
                _ActionButtons(
                  isSaving: _isSaving,
                  saveButtonFocusNode: _saveButtonFocusNode,
                  onCancel: () => context.pop(),
                  onSave: () async {
                    // Validate all prayer times before saving
                    for (int i = 0; i < prayerTimes!.length; i++) {
                      if (!_isAdhanBeforeIqamah(i)) {
                        _showValidationError(
                          "Adhan time must be before Iqamah time for ${prayerTimes![i].type.label}",
                        );
                        return;
                      }
                    }

                    await _saveUpdatedTimes();
                    if (mounted) {
                      context.pop({
                        'adjustments': adjustments,
                        'updatedPrayerTimes': prayerTimes,
                      });
                    }
                  },
                ),
              ],
            ).withPadding(p16),
          ),
        );
      },
    );
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
    final List<KeyboardActionsItem> actions = [];

    _focusNodes.forEach((prayerName, types) {
      types.forEach((timeType, fields) {
        fields.forEach((fieldType, focusNode) {
          final isLastField =
              prayerName == prayerTimes?.last.type.label &&
              timeType == 'iqamah' &&
              fieldType == 'minute';

          actions.add(
            KeyboardActionsItem(
              focusNode: focusNode,
              toolbarButtons: [
                (node) {
                  return GestureDetector(
                    onTap: () {
                      node.unfocus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                (node) {
                  return GestureDetector(
                    onTap: () async {
                      if (isLastField) {
                        // Validate before closing
                        bool allValid = true;
                        for (int i = 0; i < prayerTimes!.length; i++) {
                          if (!_isAdhanBeforeIqamah(i)) {
                            _showValidationError(
                              "Adhan time must be before Iqamah time",
                            );
                            allValid = false;
                            break;
                          }
                        }

                        if (allValid) {
                          node.unfocus();
                          await _saveUpdatedTimes();
                          if (mounted) {
                            context.pop({
                              'adjustments': adjustments,
                              'updatedPrayerTimes': prayerTimes,
                            });
                          }
                        }
                      } else {
                        node.unfocus();
                        _focusNextField(prayerName, timeType, fieldType);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        isLastField ? "Done" : "Next",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ],
            ),
          );
        });
      });
    });

    _iqamahOffsetFocusNodes.forEach((prayerName, focusNode) {
      actions.add(
        KeyboardActionsItem(
          focusNode: focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            (node) {
              return GestureDetector(
                onTap: () {
                  node.unfocus();
                  _focusNextField(prayerName, 'offset', 'offset');
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ],
        ),
      );
    });

    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      actions: actions,
    );
  }

  void _focusNextField(
    String currentPrayer,
    String currentTimeType,
    String currentFieldType,
  ) {
    final currentPrayerIndex =
        prayerTimes?.indexWhere(
          (prayer) => prayer.type.label == currentPrayer,
        ) ??
        -1;
    if (currentPrayerIndex == -1) return;

    if (currentTimeType == 'adhan') {
      if (currentFieldType == 'hour') {
        _focusNodes[currentPrayer]?['adhan']?['minute']?.requestFocus();
      } else {
        _iqamahOffsetFocusNodes[currentPrayer]?.requestFocus();
      }
    } else if (currentTimeType == 'offset') {
      _focusNodes[currentPrayer]?['iqamah']?['hour']?.requestFocus();
    } else if (currentTimeType == 'iqamah') {
      if (currentFieldType == 'hour') {
        _focusNodes[currentPrayer]?['iqamah']?['minute']?.requestFocus();
      } else {
        if (currentPrayerIndex + 1 < (prayerTimes?.length ?? 0)) {
          final nextPrayerName =
              prayerTimes![currentPrayerIndex + 1].type.label;
          _focusNodes[nextPrayerName]?['adhan']?['hour']?.requestFocus();
        }
      }
    }
  }

  void _updatePrayerTime(
    int index,
    String hourText,
    String minuteText, {
    bool isAdhan = true,
  }) {
    if (hourText.isEmpty || minuteText.isEmpty) return;
    if (prayerTimes == null) return;

    int hour = int.tryParse(hourText) ?? 0;
    int minute = int.tryParse(minuteText) ?? 0;

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return;

    final currentTime = isAdhan
        ? prayerTimes![index].time
        : prayerTimes![index].iqamahTime;
    final newTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hour,
      minute,
    );

    final prayerName = prayerTimes![index].type.label;
    final timeType = isAdhan ? 'adhan' : 'iqamah';
    _prayerTimeIsPm[prayerName]?[timeType] = hour >= 12;

    if (!_modifiedPrayerTimes.containsKey(index)) {
      _modifiedPrayerTimes[index] = {'adhan': false, 'iqamah': false};
    }
    _modifiedPrayerTimes[index]![timeType] = true;

    final originalPrayerItem = originalPrayerTimes!.firstWhere(
      (prayer) => prayer.type == prayerTimes![index].type,
      orElse: () => prayerTimes![index],
    );

    setState(() {
      if (isAdhan) {
        prayerTimes![index] = prayerTimes![index].copyWith(
          time: newTime,
          adhanStatus: "verified",
        );

        final originalAdhanTime = originalPrayerItem.time;
        final originalDateTime = DateTime(
          originalAdhanTime.year,
          originalAdhanTime.month,
          originalAdhanTime.day,
          originalAdhanTime.hour,
          originalAdhanTime.minute,
        );

        final diffMinutes = newTime.difference(originalDateTime).inMinutes;
        adjustments[index] = diffMinutes;

        _updateIqamahTimeFromOffsetWithoutSetState(index);

        // Validate after updating
        if (!_isAdhanBeforeIqamah(index)) {
          _showValidationError("Adhan time must be before Iqamah time");

          // Auto-correct: Reset iqamah to 15 minutes after the new adhan time
          final correctedIqamahTime = newTime.add(Duration(minutes: 15));
          prayerTimes![index] = prayerTimes![index].copyWith(
            iqamahTime: correctedIqamahTime,
            iqamahStatus: "verified",
          );
          _updateIqamahTimeControllersWithoutSetState(
            index,
            correctedIqamahTime,
          );
          _iqamahOffsetControllers[prayerName]?.text = '15';
        }
      } else {
        // Check if the new iqamah time is after adhan time BEFORE updating
        final adhanTime = prayerTimes![index].time;
        final adhanMinutes = adhanTime.hour * 60 + adhanTime.minute;
        final newIqamahMinutes = newTime.hour * 60 + newTime.minute;

        if (newIqamahMinutes <= adhanMinutes) {
          // Iqamah time is before or equal to adhan time - reject the change
          _showValidationError("Iqamah time must be after Adhan time");

          // Reset to previous valid time (15 minutes after adhan)
          final correctedIqamahTime = adhanTime.add(Duration(minutes: 15));
          _updateIqamahTimeControllersWithoutSetState(
            index,
            correctedIqamahTime,
          );
          _iqamahOffsetControllers[prayerName]?.text = '15';
          return; // Don't proceed with invalid time
        }

        prayerTimes![index] = prayerTimes![index].copyWith(
          iqamahTime: newTime,
          iqamahStatus: "verified",
        );

        _updateOffsetFromIqamahTimeWithoutSetState(index, newTime);
        _updateIqamahTimeControllersWithoutSetState(index, newTime);
      }
    });
  }

  void _updateIqamahTimeFromOffsetWithoutSetState(int index) {
    final prayerName = prayerTimes![index].type.label;
    final offsetText = _iqamahOffsetControllers[prayerName]?.text ?? '15';
    final offsetMinutes = int.tryParse(offsetText) ?? 15;

    final adhanTime = prayerTimes![index].time;
    final newIqamahTime = adhanTime.add(Duration(minutes: offsetMinutes));

    _updateIqamahTimeControllersWithoutSetState(index, newIqamahTime);

    prayerTimes![index] = prayerTimes![index].copyWith(
      iqamahTime: newIqamahTime,
      iqamahStatus: "verified",
    );

    if (!_modifiedPrayerTimes.containsKey(index)) {
      _modifiedPrayerTimes[index] = {'adhan': false, 'iqamah': false};
    }
    _modifiedPrayerTimes[index]!['iqamah'] = true;
  }

  void _updateIqamahTimeControllersWithoutSetState(
    int index,
    DateTime iqamahTime,
  ) {
    final prayerName = prayerTimes![index].type.label;

    final bool isPmIqamah = iqamahTime.hour >= 12;
    final int iqamahHour12 = iqamahTime.hour > 12
        ? iqamahTime.hour - 12
        : (iqamahTime.hour == 0 ? 12 : iqamahTime.hour);

    final String iqamahHour = iqamahHour12.toString().padLeft(2, '0');
    final String iqamahMinute = iqamahTime.minute.toString().padLeft(2, '0');

    if (_prayerTimeControllers[prayerName]?['iqamah'] != null) {
      _prayerTimeControllers[prayerName]!['iqamah']!['hour']!.text = iqamahHour;
      _prayerTimeControllers[prayerName]!['iqamah']!['minute']!.text =
          iqamahMinute;
    }

    _prayerTimeIsPm[prayerName]?['iqamah'] = isPmIqamah;
  }

  void _updateTimeFromControllers() {
    if (prayerTimes == null) return;

    if (_isUpdatingFromOffset) {
      return;
    }

    for (int i = 0; i < prayerTimes!.length; i++) {
      final prayerName = prayerTimes![i].type.label;

      if (_prayerTimeControllers[prayerName] != null) {
        final adhanHourText =
            _prayerTimeControllers[prayerName]!['adhan']!['hour']!.text;
        final adhanMinuteText =
            _prayerTimeControllers[prayerName]!['adhan']!['minute']!.text;
        final iqamahHourText =
            _prayerTimeControllers[prayerName]!['iqamah']!['hour']!.text;
        final iqamahMinuteText =
            _prayerTimeControllers[prayerName]!['iqamah']!['minute']!.text;

        if (adhanHourText.isNotEmpty &&
            adhanMinuteText.isNotEmpty &&
            iqamahHourText.isNotEmpty &&
            iqamahMinuteText.isNotEmpty) {
          int adhanHour = int.tryParse(adhanHourText) ?? 0;
          int adhanMinute = int.tryParse(adhanMinuteText) ?? 0;
          bool isAdhanPm = _prayerTimeIsPm[prayerName]?['adhan'] ?? false;

          if (adhanHour == 12) adhanHour = 0;
          if (isAdhanPm) adhanHour += 12;

          int iqamahHour = int.tryParse(iqamahHourText) ?? 0;
          int iqamahMinute = int.tryParse(iqamahMinuteText) ?? 0;
          bool isIqamahPm = _prayerTimeIsPm[prayerName]?['iqamah'] ?? false;

          if (iqamahHour == 12) iqamahHour = 0;
          if (isIqamahPm) iqamahHour += 12;

          if (adhanHour >= 0 &&
              adhanHour <= 23 &&
              adhanMinute >= 0 &&
              adhanMinute <= 59 &&
              iqamahHour >= 0 &&
              iqamahHour <= 23 &&
              iqamahMinute >= 0 &&
              iqamahMinute <= 59) {
            final currentTime = prayerTimes![i].time;
            final newAdhanTime = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              adhanHour,
              adhanMinute,
            );

            final newIqamahTime = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              iqamahHour,
              iqamahMinute,
            );

            setState(() {
              final originalPrayerItem = originalPrayerTimes!.firstWhere(
                (prayer) => prayer.type == prayerTimes![i].type,
                orElse: () => prayerTimes![i],
              );

              final originalTime = originalPrayerItem.time;
              final originalDateTime = DateTime(
                originalTime.year,
                originalTime.month,
                originalTime.day,
                originalTime.hour,
                originalTime.minute,
              );

              final diffMinutes = newAdhanTime
                  .difference(originalDateTime)
                  .inMinutes;

              prayerTimes![i] = prayerTimes![i].copyWith(
                time: newAdhanTime,
                iqamahTime: newIqamahTime,
                adhanStatus: "verified",
                iqamahStatus: "verified",
              );

              _updateOffsetFromIqamahTimeWithoutSetState(i, newIqamahTime);
              adjustments[i] = diffMinutes;

              // Validate after updating
              if (!_isAdhanBeforeIqamah(i)) {
                _showValidationError("Adhan time must be before Iqamah time");
              }
            });
          }
        }
      }
    }
  }

  void _updateOffsetFromIqamahTimeWithoutSetState(
    int index,
    DateTime iqamahTime,
  ) {
    final prayerName = prayerTimes![index].type.label;
    final adhanTime = prayerTimes![index].time;

    final adhanDateTime = DateTime(
      adhanTime.year,
      adhanTime.month,
      adhanTime.day,
      adhanTime.hour,
      adhanTime.minute,
    );

    final iqamahDateTime = DateTime(
      adhanTime.year,
      adhanTime.month,
      adhanTime.day,
      iqamahTime.hour,
      iqamahTime.minute,
    );

    int offsetMinutes = iqamahDateTime.difference(adhanDateTime).inMinutes;

    if (offsetMinutes < -720) {
      offsetMinutes += 1440;
    } else if (offsetMinutes > 720) {
      offsetMinutes -= 1440;
    }

    // CRITICAL FIX: Prevent negative offsets - Iqamah must be after Adhan
    if (offsetMinutes < 1) {
      // If offset is negative or zero, reset to default 15 minutes
      offsetMinutes = 15;

      // Recalculate iqamah time with the corrected offset
      final correctedIqamahTime = adhanTime.add(
        Duration(minutes: offsetMinutes),
      );

      // Update the prayer times with corrected iqamah time
      prayerTimes![index] = prayerTimes![index].copyWith(
        iqamahTime: correctedIqamahTime,
        iqamahStatus: "verified",
      );

      // Update the iqamah time controllers to show the corrected time
      _updateIqamahTimeControllersWithoutSetState(index, correctedIqamahTime);

      logger.w(
        '⚠️ Negative offset detected for ${prayerName}. Reset to 15 minutes. Iqamah must be after Adhan.',
      );
    }

    if (_iqamahOffsetControllers[prayerName] != null) {
      _iqamahOffsetControllers[prayerName]!.value = TextEditingValue(
        text: offsetMinutes.toString(),
        selection: TextSelection.collapsed(
          offset: offsetMinutes.toString().length,
        ),
      );
    }
  }

  void _updateOffset(int index, String offsetText) {
    if (offsetText.isEmpty) return;

    final offsetMinutes = int.tryParse(offsetText) ?? 15;

    // Ensure offset is positive (iqamah must be after adhan)
    if (offsetMinutes <= 0) {
      _showValidationError("Iqamah time must be after Adhan time");
      return;
    }

    final prayerName = prayerTimes![index].type.label;

    _isUpdatingFromOffset = true;

    final adhanTime = prayerTimes![index].time;
    final newIqamahTime = adhanTime.add(Duration(minutes: offsetMinutes));

    setState(() {
      _iqamahOffsetControllers[prayerName]?.text = offsetMinutes.toString();

      _updateIqamahTimeControllersWithoutSetState(index, newIqamahTime);

      prayerTimes![index] = prayerTimes![index].copyWith(
        iqamahTime: newIqamahTime,
        iqamahStatus: "verified",
      );

      if (!_modifiedPrayerTimes.containsKey(index)) {
        _modifiedPrayerTimes[index] = {'adhan': false, 'iqamah': false};
      }
      _modifiedPrayerTimes[index]!['iqamah'] = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _isUpdatingFromOffset = false;
    });
  }

  Future<void> _saveUpdatedTimes() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (int i = 0; i < prayerTimes!.length; i++) {
        if (_modifiedPrayerTimes.containsKey(i)) {
          final prayerName = prayerTimes![i].type.label;

          if (_prayerTimeControllers.containsKey(prayerName)) {
            final adhanHourText =
                _prayerTimeControllers[prayerName]!['adhan']!['hour']!.text;
            final adhanMinuteText =
                _prayerTimeControllers[prayerName]!['adhan']!['minute']!.text;

            if (adhanHourText.isNotEmpty && adhanMinuteText.isNotEmpty) {
              int adhanHour = int.tryParse(adhanHourText) ?? 0;
              int adhanMinute = int.tryParse(adhanMinuteText) ?? 0;

              bool isAdhanPm = _prayerTimeIsPm[prayerName]?['adhan'] ?? false;

              if (adhanHour == 12) adhanHour = 0;
              if (isAdhanPm) adhanHour += 12;

              adhanHour = adhanHour.clamp(0, 23);
              adhanMinute = adhanMinute.clamp(0, 59);

              final currentTime = prayerTimes![i].time;
              final newAdhanTime = DateTime(
                currentTime.year,
                currentTime.month,
                currentTime.day,
                adhanHour,
                adhanMinute,
              );

              final newIqamahTime = prayerTimes![i].iqamahTime;

              String adhanStatus = prayerTimes![i].adhanStatus;
              String iqamahStatus = prayerTimes![i].iqamahStatus;

              if (_modifiedPrayerTimes[i]!['adhan'] == true) {
                adhanStatus = "verified";
              }
              if (_modifiedPrayerTimes[i]!['iqamah'] == true) {
                iqamahStatus = "verified";
              }

              prayerTimes![i] = PrayerItem(
                type: prayerTimes![i].type,
                time: newAdhanTime,
                iqamahTime: newIqamahTime,
                isCurrent: prayerTimes![i].isCurrent,
                isUpcoming: prayerTimes![i].isUpcoming,
                showDivider: prayerTimes![i].showDivider,
                adjustment: adjustments[i],
                adhanStatus: adhanStatus,
                iqamahStatus: iqamahStatus,
              );

              final originalPrayerItem = originalPrayerTimes!.firstWhere(
                (prayer) => prayer.type == prayerTimes![i].type,
                orElse: () => prayerTimes![i],
              );
              final originalTime = originalPrayerItem.time;

              final originalTimeOfDay = Duration(
                hours: originalTime.hour,
                minutes: originalTime.minute,
              );
              final newTimeOfDay = Duration(
                hours: newAdhanTime.hour,
                minutes: newAdhanTime.minute,
              );
              final diffMinutes =
                  newTimeOfDay.inMinutes - originalTimeOfDay.inMinutes;

              adjustments[i] = diffMinutes;
            }
          }
        }
      }

      if (widget.mosqueId != null && widget.mosqueId!.isNotEmpty) {
        await _saveMosqueAdjustmentsToSupabase();
      }
    } catch (e) {
      logger.e('Error saving prayer times: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving prayer times: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveMosqueAdjustmentsToSupabase() async {
    try {
      final mosqueNotificationRepository =
          getIt<MosqueNotificationRepository>();

      int savedCount = 0;

      if (_wasReset) {
        final verifiedPrayers = <Map<String, dynamic>>[];

        for (int i = 0; i < prayerTimes!.length; i++) {
          final prayer = prayerTimes![i];
          final prayerName = prayer.type.name.toLowerCase();

          if (prayer.adhanStatus == 'verified') {
            verifiedPrayers.add({
              'prayer_name': prayerName,
              'time_type': 'adhan',
              'was_verified': true,
            });
          }

          if (prayer.iqamahStatus == 'verified') {
            verifiedPrayers.add({
              'prayer_name': prayerName,
              'time_type': 'iqamah',
              'was_verified': true,
            });
          }

          prayerTimes![i] = prayer.copyWith(
            adhanStatus: 'prediction',
            iqamahStatus: 'prediction',
          );
        }

        try {
          await mosqueNotificationRepository.resetMosqueAdjustments(
            mosqueId: widget.mosqueId!,
            mosqueName: widget.mosqueName ?? 'Unknown Mosque',
            mosqueLatitude: widget.mosqueLatitude ?? 0.0,
            mosqueLongitude: widget.mosqueLongitude ?? 0.0,
            resetBy: 'user',
            notes: 'Prayer times reset to original calculated times',
            onlyNotifyVerified: true,
            verifiedPrayers: verifiedPrayers,
            onMosqueAdjustmentUpdated: (mosqueId) {
              final mosqueRepository = getIt<MosqueRepository>();
              mosqueRepository.clearCacheForMosque(mosqueId);
            },
          );

          _wasReset = false;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Prayer times reset successfully (${verifiedPrayers.length} verified times notified)",
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          logger.e('Failed to reset mosque adjustments: $e');
          rethrow;
        }
      } else {
        for (int i = 0; i < prayerTimes!.length; i++) {
          if (_modifiedPrayerTimes.containsKey(i)) {
            final prayerName = prayerTimes![i].type.name.toLowerCase();
            final modifications = _modifiedPrayerTimes[i]!;

            final originalPrayerItem = originalPrayerTimes!.firstWhere(
              (prayer) => prayer.type == prayerTimes![i].type,
              orElse: () => prayerTimes![i],
            );

            if (modifications['adhan'] == true) {
              final originalAdhanTime = originalPrayerItem.time;
              final currentAdhanTime = prayerTimes![i].time;

              final originalTimeOfDay = Duration(
                hours: originalAdhanTime.hour,
                minutes: originalAdhanTime.minute,
              );
              final currentTimeOfDay = Duration(
                hours: currentAdhanTime.hour,
                minutes: currentAdhanTime.minute,
              );
              final adjustmentMinutes =
                  currentTimeOfDay.inMinutes - originalTimeOfDay.inMinutes;

              try {
                await mosqueNotificationRepository.updateMosquePrayerTime(
                  mosqueId: widget.mosqueId!,
                  mosqueName: widget.mosqueName ?? 'Unknown Mosque',
                  mosqueLatitude: widget.mosqueLatitude ?? 0.0,
                  mosqueLongitude: widget.mosqueLongitude ?? 0.0,
                  prayerName: prayerName,
                  timeType: 'adhan',
                  adjustmentMinutes: adjustmentMinutes,
                  onMosqueAdjustmentUpdated: (mosqueId) {
                    final mosqueRepository = getIt<MosqueRepository>();
                    mosqueRepository.clearCacheForMosque(mosqueId);
                  },
                );
                savedCount++;
              } catch (e) {
                logger.e('Failed to save $prayerName adhan adjustment: $e');
                rethrow;
              }
            }

            if (modifications['iqamah'] == true) {
              final originalAdhanTime = originalPrayerItem.time;
              final currentIqamahTime = prayerTimes![i].iqamahTime;

              final originalTimeOfDay = Duration(
                hours: originalAdhanTime.hour,
                minutes: originalAdhanTime.minute,
              );
              final iqamahTimeOfDay = Duration(
                hours: currentIqamahTime.hour,
                minutes: currentIqamahTime.minute,
              );
              final totalIqamahAdjustment =
                  iqamahTimeOfDay.inMinutes - originalTimeOfDay.inMinutes;

              try {
                await mosqueNotificationRepository.updateMosquePrayerTime(
                  mosqueId: widget.mosqueId!,
                  mosqueName: widget.mosqueName ?? 'Unknown Mosque',
                  mosqueLatitude: widget.mosqueLatitude ?? 0.0,
                  mosqueLongitude: widget.mosqueLongitude ?? 0.0,
                  prayerName: prayerName,
                  timeType: 'iqamah',
                  adjustmentMinutes: totalIqamahAdjustment,
                  onMosqueAdjustmentUpdated: (mosqueId) {
                    final mosqueRepository = getIt<MosqueRepository>();
                    mosqueRepository.clearCacheForMosque(mosqueId);
                  },
                );
                savedCount++;
              } catch (e) {
                logger.e('Failed to save $prayerName iqamah adjustment: $e');
                rethrow;
              }
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Prayer times saved successfully ($savedCount adjustments)",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error in _saveMosqueAdjustmentsToSupabase: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving to server: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      rethrow;
    }
  }
}

// Widget classes remain the same as original
class _OffsetField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int prayerIndex;
  final String prayerName;
  final Function(int, String) onOffsetChanged;
  final Function(int, bool) onFieldEditingComplete;
  final Map<int, Map<String, bool>> modifiedPrayerTimes;
  final bool isCurrentlyEditing;
  final Function(bool) onEditingStateChanged;

  const _OffsetField({
    required this.controller,
    required this.focusNode,
    required this.prayerIndex,
    required this.prayerName,
    required this.onOffsetChanged,
    required this.onFieldEditingComplete,
    required this.modifiedPrayerTimes,
    required this.isCurrentlyEditing,
    required this.onEditingStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey('offset_${prayerName}_${controller.hashCode}'),
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                _OffsetInputFormatter(),
              ],
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                hintText: 'min',
                hintStyle: TextStyle(fontSize: 10),
              ),
              onChanged: (value) {
                onEditingStateChanged(true);

                if (!modifiedPrayerTimes.containsKey(prayerIndex)) {
                  modifiedPrayerTimes[prayerIndex] = {
                    'adhan': false,
                    'iqamah': false,
                  };
                }
                modifiedPrayerTimes[prayerIndex]!['iqamah'] = true;

                onOffsetChanged(prayerIndex, value);
              },
              onTap: () {
                onEditingStateChanged(true);
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
              onFieldSubmitted: (value) async {
                FocusScope.of(context).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));
                onFieldEditingComplete(prayerIndex, false);
              },
              onEditingComplete: () {
                _validateAndFixOffset();
                onEditingStateChanged(false);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: const Text(
              'min',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndFixOffset() {
    String text = controller.text;

    if (text.isEmpty) {
      controller.text = '15';
      onOffsetChanged(prayerIndex, '15');
    } else {
      int offsetValue = int.tryParse(text) ?? 15;
      if (offsetValue < 1) {
        controller.text = '1';
        onOffsetChanged(prayerIndex, '1');
      } else if (offsetValue > 999) {
        controller.text = '999';
        onOffsetChanged(prayerIndex, '999');
      }
    }
  }
}

class _OffsetInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) return newValue;

    int? value = int.tryParse(text);

    if (value == null || value < 1 || value > 999) {
      return oldValue;
    }

    return newValue;
  }
}

class _UpdatePrayerTimesHeader extends StatelessWidget {
  final VoidCallback onReset;

  const _UpdatePrayerTimesHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr(LocaleKeys.manualCorrection),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: context.onSurfaceColor,
          ),
        ),
        TextButton(
          onPressed: onReset,
          child: Text(
            context.tr(LocaleKeys.reset),
            style: TextStyle(
              color: context.primaryColor.withValues(alpha: .6),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrayerTimesTable extends StatelessWidget {
  final List<PrayerItem>? prayerTimes;
  final Map<String, Map<String, Map<String, TextEditingController>>>
  prayerTimeControllers;
  final Map<String, Map<String, bool>> prayerTimeIsPm;
  final Map<String, Map<String, Map<String, FocusNode>>> focusNodes;
  final Map<String, TextEditingController> iqamahOffsetControllers;
  final Map<String, FocusNode> iqamahOffsetFocusNodes;
  final Function(int, String, String, bool) onTimeChanged;
  final Function(String, String, bool) onAmPmToggled;
  final Function(int, String) onOffsetChanged;
  final Function(int, bool) onFieldEditingComplete;
  final Map<int, Map<String, bool>> modifiedPrayerTimes;
  final bool isCurrentlyEditing;
  final Function(bool) onEditingStateChanged;
  final Function()? onTimeUpdate;

  const _PrayerTimesTable({
    required this.prayerTimes,
    required this.prayerTimeControllers,
    required this.prayerTimeIsPm,
    required this.focusNodes,
    required this.iqamahOffsetControllers,
    required this.iqamahOffsetFocusNodes,
    required this.onTimeChanged,
    required this.onAmPmToggled,
    required this.onOffsetChanged,
    required this.onFieldEditingComplete,
    required this.modifiedPrayerTimes,
    required this.isCurrentlyEditing,
    required this.onEditingStateChanged,
    this.onTimeUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Prayer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Adhan Time',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Offset',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Iqamah Time',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        gapH8,
        ...prayerTimes?.asMap().entries.map((entry) {
              final index = entry.key;
              final prayer = entry.value;
              final prayerName = prayer.type.label;

              if (!prayerTimeControllers.containsKey(prayerName))
                return SizedBox.shrink();

              final timeTypes = prayerTimeControllers[prayerName]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(prayerName, style: TextStyle(fontSize: 12)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: _SplitTimeField(
                          hourController: timeTypes['adhan']!['hour']!,
                          minuteController: timeTypes['adhan']!['minute']!,
                          hourFocusNode:
                              focusNodes[prayerName]?['adhan']?['hour'],
                          minuteFocusNode:
                              focusNodes[prayerName]?['adhan']?['minute'],
                          prayerIndex: index,
                          isAdhan: true,
                          prayerName: prayerName,
                          isPm: prayerTimeIsPm[prayerName]?['adhan'] ?? false,
                          onTimeChanged: onTimeChanged,
                          onAmPmToggled: onAmPmToggled,
                          onFieldEditingComplete: onFieldEditingComplete,
                          modifiedPrayerTimes: modifiedPrayerTimes,
                          isCurrentlyEditing: isCurrentlyEditing,
                          onEditingStateChanged: onEditingStateChanged,
                          onTimeUpdate: onTimeUpdate,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: _OffsetField(
                          controller: iqamahOffsetControllers[prayerName]!,
                          focusNode: iqamahOffsetFocusNodes[prayerName]!,
                          prayerIndex: index,
                          prayerName: prayerName,
                          onOffsetChanged: onOffsetChanged,
                          onFieldEditingComplete: onFieldEditingComplete,
                          modifiedPrayerTimes: modifiedPrayerTimes,
                          isCurrentlyEditing: isCurrentlyEditing,
                          onEditingStateChanged: onEditingStateChanged,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: _SplitTimeField(
                          hourController: timeTypes['iqamah']!['hour']!,
                          minuteController: timeTypes['iqamah']!['minute']!,
                          hourFocusNode:
                              focusNodes[prayerName]?['iqamah']?['hour'],
                          minuteFocusNode:
                              focusNodes[prayerName]?['iqamah']?['minute'],
                          prayerIndex: index,
                          isAdhan: false,
                          prayerName: prayerName,
                          isPm: prayerTimeIsPm[prayerName]?['iqamah'] ?? false,
                          onTimeChanged: onTimeChanged,
                          onAmPmToggled: onAmPmToggled,
                          onFieldEditingComplete: onFieldEditingComplete,
                          modifiedPrayerTimes: modifiedPrayerTimes,
                          isCurrentlyEditing: isCurrentlyEditing,
                          onEditingStateChanged: onEditingStateChanged,
                          onTimeUpdate: onTimeUpdate,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList() ??
            [],
      ],
    );
  }
}

class _SplitTimeField extends StatelessWidget {
  final TextEditingController hourController;
  final TextEditingController minuteController;
  final FocusNode? hourFocusNode;
  final FocusNode? minuteFocusNode;
  final int prayerIndex;
  final bool isAdhan;
  final String prayerName;
  final bool isPm;
  final Function(int, String, String, bool) onTimeChanged;
  final Function(String, String, bool) onAmPmToggled;
  final Function(int, bool) onFieldEditingComplete;
  final Map<int, Map<String, bool>> modifiedPrayerTimes;
  final bool isCurrentlyEditing;
  final Function(bool) onEditingStateChanged;
  final Function()? onTimeUpdate;

  const _SplitTimeField({
    required this.hourController,
    required this.minuteController,
    this.hourFocusNode,
    this.minuteFocusNode,
    required this.prayerIndex,
    required this.isAdhan,
    required this.prayerName,
    required this.isPm,
    required this.onTimeChanged,
    required this.onAmPmToggled,
    required this.onFieldEditingComplete,
    required this.modifiedPrayerTimes,
    required this.isCurrentlyEditing,
    required this.onEditingStateChanged,
    this.onTimeUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          _TimeInputField(
            controller: hourController,
            focusNode: hourFocusNode,
            isHour: true,
            prayerIndex: prayerIndex,
            isAdhan: isAdhan,
            prayerName: prayerName,
            isPm: isPm,
            onTimeChanged: onTimeChanged,
            onEditingStateChanged: onEditingStateChanged,
            modifiedPrayerTimes: modifiedPrayerTimes,
            isCurrentlyEditing: isCurrentlyEditing,
            onTimeUpdate: onTimeUpdate,
          ).expanded(),

          const Text(
            ':',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          _TimeInputField(
            controller: minuteController,
            focusNode: minuteFocusNode,
            isHour: false,
            prayerIndex: prayerIndex,
            isAdhan: isAdhan,
            prayerName: prayerName,
            isPm: isPm,
            onTimeChanged: onTimeChanged,
            onEditingStateChanged: onEditingStateChanged,
            modifiedPrayerTimes: modifiedPrayerTimes,
            isCurrentlyEditing: isCurrentlyEditing,
            onFieldEditingComplete: onFieldEditingComplete,
            onTimeUpdate: onTimeUpdate,
            hourController: hourController,
          ).expanded(),

          _AmPmToggle(
            isPm: isPm,
            prayerName: prayerName,
            isAdhan: isAdhan,
            onAmPmToggled: onAmPmToggled,
            prayerIndex: prayerIndex,
            hourController: hourController,
            minuteController: minuteController,
            onTimeChanged: onTimeChanged,
            modifiedPrayerTimes: modifiedPrayerTimes,
            onTimeUpdate: onTimeUpdate,
          ),
        ],
      ),
    );
  }
}

class _TimeInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isHour;
  final int prayerIndex;
  final bool isAdhan;
  final String prayerName;
  final bool isPm;
  final Function(int, String, String, bool) onTimeChanged;
  final Function(bool) onEditingStateChanged;
  final Map<int, Map<String, bool>> modifiedPrayerTimes;
  final bool isCurrentlyEditing;
  final Function(int, bool)? onFieldEditingComplete;
  final Function()? onTimeUpdate;
  final TextEditingController? hourController;

  const _TimeInputField({
    required this.controller,
    this.focusNode,
    required this.isHour,
    required this.prayerIndex,
    required this.isAdhan,
    required this.prayerName,
    required this.isPm,
    required this.onTimeChanged,
    required this.onEditingStateChanged,
    required this.modifiedPrayerTimes,
    required this.isCurrentlyEditing,
    this.onFieldEditingComplete,
    this.onTimeUpdate,
    this.hourController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      textInputAction: isHour ? TextInputAction.next : TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
        isHour ? _Hour12InputFormatter() : _MinuteInputFormatter(),
      ],
      style: const TextStyle(fontSize: 12),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      onChanged: (value) {
        onEditingStateChanged(true);

        final timeType = isAdhan ? 'adhan' : 'iqamah';
        if (!modifiedPrayerTimes.containsKey(prayerIndex)) {
          modifiedPrayerTimes[prayerIndex] = {'adhan': false, 'iqamah': false};
        }
        modifiedPrayerTimes[prayerIndex]![timeType] = true;

        if (onTimeUpdate != null) {
          onTimeUpdate!();
        }

        if (value.length == 2 && isHour) {
          FocusScope.of(context).nextFocus();
        }
      },
      onTap: () {
        onEditingStateChanged(true);
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      onFieldSubmitted: !isHour && onFieldEditingComplete != null
          ? (value) async {
              FocusScope.of(context).unfocus();
              await Future.delayed(const Duration(milliseconds: 100));

              if (onFieldEditingComplete != null) {
                await onFieldEditingComplete!(prayerIndex, isAdhan);
              }
            }
          : null,
      onEditingComplete: () {
        _validateAndFixTime();
        onEditingStateChanged(false);
      },
    );
  }

  void _validateAndFixTime() {
    String text = controller.text;

    if (isHour) {
      if (text.isEmpty) {
        controller.text = '12';
        text = '12';
      } else if (text.length == 1) {
        controller.text = text.padLeft(2, '0');
      } else if (text == '00') {
        controller.text = '12';
        text = '12';
      } else {
        int hourValue = int.tryParse(text) ?? 0;
        if (hourValue < 1) {
          controller.text = '01';
          text = '01';
        } else if (hourValue > 12) {
          controller.text = '12';
          text = '12';
        }
      }

      int hourValue = int.tryParse(text) ?? 12;
      if (hourValue == 12) hourValue = 0;
      if (isPm) hourValue += 12;

      onTimeChanged(prayerIndex, hourValue.toString(), '0', isAdhan);
    } else {
      if (text.isEmpty) {
        controller.text = '00';
        text = '00';
      } else if (text.length == 1) {
        controller.text = text.padLeft(2, '0');
      } else {
        int minuteValue = int.tryParse(text) ?? 0;
        if (minuteValue > 59) {
          controller.text = '59';
          text = '59';
        }
      }

      final hourText = isHour
          ? controller.text
          : (hourController?.text ?? '12');
      int hourValue = int.tryParse(hourText) ?? 12;
      if (hourValue == 12) hourValue = 0;
      if (isPm) hourValue += 12;

      onTimeChanged(prayerIndex, hourValue.toString(), text, isAdhan);
    }
  }
}

class _AmPmToggle extends StatelessWidget {
  final bool isPm;
  final String prayerName;
  final bool isAdhan;
  final Function(String, String, bool) onAmPmToggled;
  final int prayerIndex;
  final TextEditingController hourController;
  final TextEditingController minuteController;
  final Function(int, String, String, bool) onTimeChanged;
  final Map<int, Map<String, bool>> modifiedPrayerTimes;
  final Function()? onTimeUpdate;

  const _AmPmToggle({
    required this.isPm,
    required this.prayerName,
    required this.isAdhan,
    required this.onAmPmToggled,
    required this.prayerIndex,
    required this.hourController,
    required this.minuteController,
    required this.onTimeChanged,
    required this.modifiedPrayerTimes,
    this.onTimeUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final timeType = isAdhan ? 'adhan' : 'iqamah';

        if (!modifiedPrayerTimes.containsKey(prayerIndex)) {
          modifiedPrayerTimes[prayerIndex] = {'adhan': false, 'iqamah': false};
        }
        modifiedPrayerTimes[prayerIndex]![timeType] = true;

        int hour = int.tryParse(hourController.text) ?? 0;
        if (hour == 0) hour = 12;

        onAmPmToggled(prayerName, timeType, isPm);

        if (hourController.text.isNotEmpty) {
          int hour24;
          if (isPm) {
            hour24 = hour == 12 ? 0 : hour;
          } else {
            hour24 = hour == 12 ? 12 : hour + 12;
          }

          onTimeChanged(
            prayerIndex,
            hour24.toString(),
            minuteController.text,
            isAdhan,
          );

          if (onTimeUpdate != null) {
            onTimeUpdate!();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.center,
        child: Text(
          isPm ? 'PM' : 'AM',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isSaving;
  final FocusNode saveButtonFocusNode;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ActionButtons({
    required this.isSaving,
    required this.saveButtonFocusNode,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButtonView(
          text: context.tr(LocaleKeys.cancel),
          width: context.width / 2 - 24,
          height: 40,
          onPressed: onCancel,
        ),
        isSaving
            ? Container(
                width: context.width / 2 - 24,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: context.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Focus(
                focusNode: saveButtonFocusNode,
                child: OutlinedButtonView(
                  text: context.tr(LocaleKeys.save),
                  width: context.width / 2 - 24,
                  height: 40,
                  onPressed: onSave,
                ),
              ),
      ],
    );
  }
}

class _MinuteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) return newValue;

    int? value = int.tryParse(text);

    if (value == null || value < 0 || value > 59) {
      return oldValue;
    }

    return newValue;
  }
}

class _Hour12InputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) return newValue;

    int? value = int.tryParse(text);

    if (value == null || value < 1 || value > 12) {
      return oldValue;
    }

    return newValue;
  }
}
