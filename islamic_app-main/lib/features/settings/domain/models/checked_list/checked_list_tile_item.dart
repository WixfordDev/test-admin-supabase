import 'package:freezed_annotation/freezed_annotation.dart';

part 'checked_list_tile_item.freezed.dart';

@freezed
abstract class CheckedListTileItem with _$CheckedListTileItem {
  const factory CheckedListTileItem({
    required String value,
    required String title,
    String? subtitle,
    String? description,
    String? uri,
    String? assetUri,
  }) = _CheckedListTileItem;
}
