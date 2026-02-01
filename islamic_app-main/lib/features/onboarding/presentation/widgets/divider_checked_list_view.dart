import 'package:flutter/cupertino.dart';
import 'package:deenhub/core/widgets/common_widgets.dart';
import 'package:deenhub/features/onboarding/presentation/widgets/checked_list_tile_view.dart';
import 'package:deenhub/features/settings/domain/models/checked_list/checked_list_tile_item.dart';

class DividerCheckedListView extends StatelessWidget {
  final List<CheckedListTileItem> list;
  final String? groupValue;
  final bool scrollable;
  final bool shrinkWrap;
  final bool showScrollbar;
  final void Function(String?)? onTap;

  const DividerCheckedListView({
    super.key,
    required this.list,
    required this.groupValue,
    this.scrollable = true,
    this.shrinkWrap = true,
    this.showScrollbar = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return showScrollbar ? CupertinoScrollbar(child: _buildListView()) : _buildListView();
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: list.length,
      shrinkWrap: shrinkWrap,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const AppDivider(),
      itemBuilder: (context, index) {
        final item = list[index];
        return CheckedListTileView(
          item: item,
          groupValue: groupValue,
          onTap: onTap,
        );
      },
    );
  }
}
