import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

const freezedOnBloc = Freezed(
  copyWith: false,
  equal: true,
  fromJson: false,
  toJson: false,
  map: FreezedMapOptions(map: true, mapOrNull: false, maybeMap: true),
  when: FreezedWhenOptions(when: true, whenOrNull: true, maybeWhen: true),
);

const freezedOnBlocState = Freezed(
  copyWith: true,
  equal: true,
  fromJson: false,
  toJson: false,
  map: FreezedMapOptions(map: false, mapOrNull: false, maybeMap: false),
  when: FreezedWhenOptions(when: false, whenOrNull: false, maybeWhen: false),
);

const freezedOnSharedPrefDataClass = Freezed(
  copyWith: true,
  equal: false,
  fromJson: true,
  toJson: true,
  map: FreezedMapOptions(map: false, mapOrNull: false, maybeMap: false),
  when: FreezedWhenOptions(when: false, whenOrNull: false, maybeWhen: false),
);

extension NumExt on num {
  // Padding
  EdgeInsetsDirectional get allPadding => EdgeInsetsDirectional.all(toDouble());
  EdgeInsetsDirectional get verticalPadding =>
      EdgeInsetsDirectional.symmetric(vertical: toDouble());
  EdgeInsetsDirectional get horizontalPadding =>
      EdgeInsetsDirectional.symmetric(horizontal: toDouble());

  EdgeInsetsDirectional get startPadding => EdgeInsetsDirectional.only(start: toDouble());
  EdgeInsetsDirectional get endPadding => EdgeInsetsDirectional.only(end: toDouble());
  EdgeInsetsDirectional get topPadding => EdgeInsetsDirectional.only(top: toDouble());
  EdgeInsetsDirectional get bottomPadding => EdgeInsetsDirectional.only(bottom: toDouble());

  // Border
  OutlinedBorder roundedBorder({
    BorderSide side = BorderSide.none,
  }) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.circular(toDouble()),
        side: side,
      );

  // Duration
  Duration get microseconds => Duration(microseconds: toInt());
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());
}
