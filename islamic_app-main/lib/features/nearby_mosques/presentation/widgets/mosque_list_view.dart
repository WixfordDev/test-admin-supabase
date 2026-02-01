import 'package:flutter/material.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/features/nearby_mosques/presentation/widgets/nearby_mosque_card.dart';

class MosqueListView extends StatefulWidget {
  final List<Mosque> mosques;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? emptyStateMessage;
  final String? loadingMessage;
  final bool showFavoriteButton;
  final Function(Mosque, int)? onMosqueUpdated;
  final Function(Mosque, int)? onFavoriteToggled;

  const MosqueListView({
    super.key,
    required this.mosques,
    this.isLoading = false,
    this.onRefresh,
    this.emptyStateMessage = 'No mosques found in this area',
    this.loadingMessage = 'Searching Mosques',
    this.showFavoriteButton = true,
    this.onMosqueUpdated,
    this.onFavoriteToggled,
  });

  @override
  State<MosqueListView> createState() => _MosqueListViewState();
}

class _MosqueListViewState extends State<MosqueListView> {
  int expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(widget.loadingMessage!),
          ],
        ),
      );
    }

    if (widget.mosques.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: ListView.builder(
        itemCount: widget.mosques.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final mosque = widget.mosques[index];
          return NearbyMosqueCard(
            key: ValueKey('mosque_${mosque.name}_$index'),
            mosque: mosque,
            isExpanded: expandedIndex == index,
            onTap: () {
              setState(() {
                expandedIndex = index;
              });
            },
            showFavoriteButton: widget.showFavoriteButton,
            onPrayerTimesUpdated: (updatedMosque) {
              if (widget.onMosqueUpdated != null) {
                widget.onMosqueUpdated!(updatedMosque, index);
              }
            },
            onFavoriteToggled: (updatedMosque) {
              if (widget.onFavoriteToggled != null) {
                widget.onFavoriteToggled!(updatedMosque, index);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mosque_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyStateMessage!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add mosques to your favorites from the main mosques screen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.onRefresh != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ],
      ),
    );
  }
}
