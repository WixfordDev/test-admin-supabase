import 'package:deenhub/common/enums/prayer_types.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/date_time_utils.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
import 'package:deenhub/features/nearby_mosques/presentation/pages/update_prayer_times_bottom_sheet_view.dart';
import 'package:deenhub/features/nearby_mosques/presentation/pages/edit_mosque_facilities_bottom_sheet.dart';
import 'package:deenhub/features/nearby_mosques/data/models/mosque_facility.dart';
import 'package:deenhub/config/gen/locale_keys.gen.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NearbyMosqueCard extends StatefulWidget {
  final Mosque mosque;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool showFavoriteButton;
  final Function(Mosque)? onPrayerTimesUpdated;
  final Function(Mosque)? onFavoriteToggled;

  const NearbyMosqueCard({
    super.key,
    required this.mosque,
    required this.isExpanded,
    required this.onTap,
    this.showFavoriteButton = true,
    this.onPrayerTimesUpdated,
    this.onFavoriteToggled,
  });

  @override
  State<NearbyMosqueCard> createState() => _NearbyMosqueCardState();
}

class _NearbyMosqueCardState extends State<NearbyMosqueCard>
    with TickerProviderStateMixin {
  late bool isFav;
  late Mosque mosque;
  bool _isUpdatingFavorite = false;

  @override
  void initState() {
    super.initState();
    mosque = widget.mosque;
    isFav = mosque.isFavorite;
  }

  @override
  void didUpdateWidget(NearbyMosqueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the local mosque if it's a different mosque (by reference comparison)
    // This prevents overriding our local updates when the parent rebuilds
    if (widget.mosque != oldWidget.mosque && mosque == oldWidget.mosque) {
      mosque = widget.mosque;
      isFav = mosque.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add safety check for empty prayer times
    final prayerTimes = mosque.prayerTimes;
    String upcomingPrayerInfo;

    if (prayerTimes.isEmpty) {
      upcomingPrayerInfo = 'No prayer times available';
    } else {
      try {
        final upcomingPrayer = prayerTimes.firstWhere((e) => e.isUpcoming,
            orElse: () => prayerTimes.first);
        upcomingPrayerInfo =
            '🕒 Next: ${upcomingPrayer.type.label} at ${upcomingPrayer.time.time()}';
      } catch (e) {
        // Fallback if something goes wrong
        upcomingPrayerInfo = '🕒 Prayer times available';
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                spreadRadius: 1),
          ],
        ),
        child: Column(
          children: [
            _MosqueCardHeader(
              mosque: mosque,
              upcomingPrayerInfo: upcomingPrayerInfo,
              isFav: isFav,
              isUpdatingFavorite: _isUpdatingFavorite,
              onTap: widget.onTap,
              onToggleFavorite: _toggleFavorite,
              onDirections: () => _openDirections(mosque),
            ),
            if (widget.isExpanded) ...[
              const Divider(thickness: 1),
              _ExpandedContent(
                mosque: mosque,
                onPrayerTimesUpdated: (result) async {
                  // Handle the returned data
                  if (result != null && mounted) {
                    // Get the updated prayer times
                    final updatedAdjustments = result['adjustments'];
                    final updatedPrayerTimes = result['updatedPrayerTimes'];

                    // Update the mosque data
                    if (mosque.locData != null && updatedPrayerTimes != null) {
                      // Create updated location data
                      final updatedLocData = mosque.locData!.copyWith(
                        adjustments: updatedAdjustments,
                        prayerTimes: updatedPrayerTimes,
                      );

                      // Create a new Mosque instance to avoid reference issues
                      final updatedMosque = mosque.copyWith(
                        locData: updatedLocData,
                        prayerTimes: updatedPrayerTimes,
                      );

                      setState(() {
                        // Update our local state with the new mosque
                        mosque = updatedMosque;
                      });

                      // Notify parent about the prayer times update
                      if (widget.onPrayerTimesUpdated != null) {
                        widget.onPrayerTimesUpdated!(updatedMosque);
                      }
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isUpdatingFavorite) return;

    setState(() {
      _isUpdatingFavorite = true;
    });

    try {
      final mosqueRepository = getIt<MosqueRepository>();

      if (isFav) {
        // Remove from favorites (no authentication required)
        await mosqueRepository.removeFromFavorites(mosque);
        if (mounted) {
          setState(() {
            isFav = false;
            mosque = mosque.copyWith(isFavorite: false);
          });

          context.showSnackBar(
            "Removed from favorites",
            behavior: SnackBarBehavior.floating,
          );
        }
      } else {
        // Add to favorites (no authentication required)
        await mosqueRepository.addToFavorites(mosque);
        if (mounted) {
          setState(() {
            isFav = true;
            mosque = mosque.copyWith(isFavorite: true);
          });

          context.showSnackBar(
            "Added to favorites",
            behavior: SnackBarBehavior.floating,
          );
        }
      }

      // Notify parent about the favorite status change
      if (widget.onFavoriteToggled != null) {
        widget.onFavoriteToggled!(mosque);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFavorite = false;
        });
      }
    }
  }

  void _openDirections(Mosque mosque) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}';

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to open in any available app
        await launchUrlString(url);
      }
    } catch (e) {
      // Handle error - could show a snackbar or toast
      debugPrint('Could not launch directions: $e');
    }
  }
}

// Separate stateless widgets for better performance
class _MosqueCardHeader extends StatelessWidget {
  final Mosque mosque;
  final String upcomingPrayerInfo;
  final bool isFav;
  final bool isUpdatingFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDirections;

  const _MosqueCardHeader({
    required this.mosque,
    required this.upcomingPrayerInfo,
    required this.isFav,
    required this.isUpdatingFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MosqueHeaderRow(
              mosque: mosque,
            ),
            gapH4,
            _MosqueInfoRow(
              mosque: mosque,
              upcomingPrayerInfo: upcomingPrayerInfo,
              onToggleFavorite: onToggleFavorite,
              isFav: isFav,
              isUpdatingFavorite: isUpdatingFavorite,
              onDirections: onDirections,
            ),
          ],
        ),
      ),
    );
  }
}

class _MosqueHeaderRow extends StatelessWidget {
  final Mosque mosque;

  const _MosqueHeaderRow({
    required this.mosque,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            mosque.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '📍 ${mosque.distance.toStringAsFixed(2)} ${mosque.unit} away',
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class _MosqueInfoRow extends StatelessWidget {
  final Mosque mosque;
  final String upcomingPrayerInfo;
  final bool isFav;
  final bool isUpdatingFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDirections;

  const _MosqueInfoRow({
    required this.mosque,
    required this.upcomingPrayerInfo,
    required this.isFav,
    required this.isUpdatingFavorite,
    required this.onToggleFavorite,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mosque.address,
                style: TextStyle(color: Colors.grey[600]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  upcomingPrayerInfo,
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        _MosqueActions(
          mosque: mosque,
          isFav: isFav,
          isUpdatingFavorite: isUpdatingFavorite,
          onToggleFavorite: onToggleFavorite,
          onDirections: onDirections,
        ),
      ],
    );
  }
}

class _MosqueActions extends StatelessWidget {
  final Mosque mosque;
  final bool isFav;
  final bool isUpdatingFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDirections;

  const _MosqueActions({
    required this.mosque,
    required this.isFav,
    required this.isUpdatingFavorite,
    required this.onToggleFavorite,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isUpdatingFavorite
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: onToggleFavorite,
              ),
        InkWell(
          onTap: onDirections,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Icon(Icons.directions, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Directions',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final Mosque mosque;
  final Function(dynamic) onPrayerTimesUpdated;

  const _ExpandedContent({
    required this.mosque,
    required this.onPrayerTimesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _PrayerTimesSection(
            mosque: mosque,
            onPrayerTimesUpdated: onPrayerTimesUpdated,
          ),
          gapH12,
          FacilitiesScreen(
            mosqueId: mosque.placeId,
            mosqueName: mosque.name,
            latitude: mosque.latitude,
            longitude: mosque.longitude,
            address: mosque.address,
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesSection extends StatelessWidget {
  final Mosque mosque;
  final Function(dynamic) onPrayerTimesUpdated;

  const _PrayerTimesSection({
    required this.mosque,
    required this.onPrayerTimesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrayerTimesSectionHeader(
          mosque: mosque,
          onPrayerTimesUpdated: onPrayerTimesUpdated,
        ),
        gapH8,
        _PrayerTimesContent(mosque: mosque),
        _PrayerTimesLegend(),
      ],
    );
  }
}

class _PrayerTimesSectionHeader extends StatelessWidget {
  final Mosque mosque;
  final Function(dynamic) onPrayerTimesUpdated;

  const _PrayerTimesSectionHeader({
    required this.mosque,
    required this.onPrayerTimesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Prayer Times", style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        InkWellView(
          onTap: () async {
            final result = await context.showBottomSheetNow(
              isScrollControlled: true,
              child: UpdatePrayerTimesBottomSheetView(
                locData: mosque.locData!,
                mosqueId: mosque.placeId,
                mosqueName: mosque.name,
                mosqueLatitude: mosque.latitude,
                mosqueLongitude: mosque.longitude,
              ),
            );
            onPrayerTimesUpdated(result);
          },
          child: const Text(
            "Update",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class _PrayerTimesContent extends StatelessWidget {
  final Mosque mosque;

  const _PrayerTimesContent({required this.mosque});

  @override
  Widget build(BuildContext context) {
    if (mosque.prayerTimes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "No prayer times available",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      children: mosque.prayerTimes.map((e) {
        return _PrayerTimeCard(prayerItem: e);
      }).toList(),
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  final PrayerItem prayerItem;

  const _PrayerTimeCard({required this.prayerItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prayer Name
          Text(
            _getPrayerLabel(prayerItem),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          // Adhan & Iqamah Times with Indicator
          if (prayerItem.type == PrayerType.sunrise) ...[
            Text(
              prayerItem.time.time(),
              style: TextStyle(fontSize: 14, color: Colors.blue.shade800),
            ),
          ],
          if (prayerItem.type != PrayerType.sunrise) ...[
            _PrayerTimeDetails(prayerItem: prayerItem),
          ]
        ],
      ),
    );
  }

  // Helper method to get prayer label (handles Friday Jumaah)
  String _getPrayerLabel(dynamic prayerItem) {
    if (prayerItem.time.weekday == DateTime.friday &&
        prayerItem.type == PrayerType.dhuhr) {
      return LocaleKeys.jumaah.tr();
    }
    return prayerItem.type.label;
  }
}

class _PrayerTimeDetails extends StatelessWidget {
  final PrayerItem prayerItem;

  const _PrayerTimeDetails({required this.prayerItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              "Adhan",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(width: 6),
            Text(
              prayerItem.time.time(),
              style: TextStyle(fontSize: 14, color: Colors.blue.shade800),
            ),
            const SizedBox(width: 4),
            _buildStatusDot(prayerItem.adhanStatus),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "Iqamah",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(width: 6),
            Text(
              prayerItem.iqamahTime.time(),
              style: TextStyle(fontSize: 14, color: Colors.green.shade700),
            ),
            const SizedBox(width: 4),
            _buildStatusDot(prayerItem.iqamahStatus),
          ],
        ),
      ],
    );
  }

  // **Dot Indicator Widget**
  Widget _buildStatusDot(String status) {
    Color dotColor;
    switch (status) {
      case "verified":
        dotColor = Colors.green;
        break;
      case "prediction":
        dotColor = Colors.yellow;
        break;
      case "unknown":
        dotColor = Colors.white;
        break;
      default:
        dotColor = Colors.white;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black45),
      ),
    );
  }
}

class _PrayerTimesLegend extends StatelessWidget {
  const _PrayerTimesLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem("Verified", "verified"),
            const SizedBox(width: 16),
            _buildLegendItem("Predicted", "prediction"),
            const SizedBox(width: 16),
            _buildLegendItem("Unknown", "unknown"),
          ],
        ),
      ),
    );
  }

  // Legend item widget
  Widget _buildLegendItem(String label, String status) {
    return Row(
      children: [
        _buildStatusDot(status),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // **Dot Indicator Widget**
  Widget _buildStatusDot(String status) {
    Color dotColor;
    switch (status) {
      case "verified":
        dotColor = Colors.green;
        break;
      case "prediction":
        dotColor = Colors.yellow;
        break;
      case "unknown":
        dotColor = Colors.white;
        break;
      default:
        dotColor = Colors.white;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black45),
      ),
    );
  }
}

class FacilitiesScreen extends StatefulWidget {
  final String? mosqueId;
  final String? mosqueName;
  final double? latitude;
  final double? longitude;
  final String? address;

  const FacilitiesScreen({
    super.key,
    this.mosqueId,
    this.mosqueName,
    this.latitude,
    this.longitude,
    this.address,
  });

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _mosqueRepository = getIt<MosqueRepository>();
  Map<String, List<MosqueFacility>> _facilitiesByCategory = {
    'General': [],
    'For Women': [],
    'Accessibility': [],
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.mosqueId != null) {
      _loadFacilities();
    }
  }

  Future<void> _loadFacilities() async {
    if (widget.mosqueId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final facilitiesByCategory = await _mosqueRepository
          .getMosqueFacilitiesByCategory(widget.mosqueId!);
      setState(() {
        _facilitiesByCategory = facilitiesByCategory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text(
                  "Facilities",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ).expanded(),
                if (widget.mosqueId != null && widget.mosqueName != null)
                  InkWell(
                    onTap: () async {
                      final result = await context.showBottomSheetNow(
                        isScrollControlled: true,
                        child: EditMosqueFacilitiesBottomSheet(
                          mosqueId: widget.mosqueId!,
                          mosqueName: widget.mosqueName!,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          address: widget.address,
                        ),
                      );

                      // Reload facilities if changes were saved
                      if (result == true) {
                        _loadFacilities();
                      }
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )
          else ...[
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.green,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: "General"),
                Tab(text: "For Women"),
                Tab(text: "Accessibility"),
              ],
            ),
            TabBarView(
              controller: _tabController,
              children: [
                FacilitiesList(
                    facilities: _facilitiesByCategory['General'] ?? []),
                FacilitiesList(
                    facilities: _facilitiesByCategory['For Women'] ?? []),
                FacilitiesList(
                    facilities: _facilitiesByCategory['Accessibility'] ?? []),
              ],
            ).box(height: (24 + 4) * 5 + 16),
          ],
        ],
      ),
    );
  }
}

class FacilitiesList extends StatelessWidget {
  final List<MosqueFacility> facilities;

  const FacilitiesList({
    super.key,
    required this.facilities,
  });

  @override
  Widget build(BuildContext context) {
    // Use default facilities if no real data is available
    final displayFacilities =
        facilities.isEmpty ? _getDefaultFacilities() : facilities;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: displayFacilities.length,
      itemBuilder: (context, index) {
        final facility = displayFacilities[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFacilityIcon(facility.availability),
              color: _getFacilityColor(facility.availability),
            ),
            gapW8,
            Text(_getFacilityText(facility)).expanded(),
          ],
        ).withPadding(py2);
      },
    );
  }

  // Default facilities to show when no real data is available
  List<MosqueFacility> _getDefaultFacilities() {
    return [
      const MosqueFacility(
        mosqueId: 'default',
        facilityType: FacilityType.parking,
        availability: FacilityAvailability.unknown,
        description: 'On premise parking',
      ),
      const MosqueFacility(
        mosqueId: 'default',
        facilityType: FacilityType.wudu,
        availability: FacilityAvailability.available,
        description: 'Odhu facility',
      ),
      const MosqueFacility(
        mosqueId: 'default',
        facilityType: FacilityType.toilets,
        availability: FacilityAvailability.available,
        description: 'Toilets facility',
      ),
      const MosqueFacility(
        mosqueId: 'default',
        facilityType: FacilityType.shower,
        availability: FacilityAvailability.notAvailable,
        description: 'Shower facility',
      ),
    ];
  }

  IconData _getFacilityIcon(FacilityAvailability availability) {
    switch (availability) {
      case FacilityAvailability.available:
      case FacilityAvailability.easilyAvailable:
        return Icons.check_circle;
      case FacilityAvailability.notAvailable:
        return Icons.cancel;
      case FacilityAvailability.limitedAvailability:
        return Icons.warning;
      case FacilityAvailability.unknown:
        return Icons.help;
    }
  }

  Color _getFacilityColor(FacilityAvailability availability) {
    switch (availability) {
      case FacilityAvailability.available:
      case FacilityAvailability.easilyAvailable:
        return Colors.green;
      case FacilityAvailability.notAvailable:
        return Colors.red;
      case FacilityAvailability.limitedAvailability:
        return Colors.orange;
      case FacilityAvailability.unknown:
        return Colors.grey;
    }
  }

  String _getFacilityText(MosqueFacility facility) {
    final displayName = facility.facilityType.displayName;
    final status = facility.availability.displayText.toLowerCase();

    String text = "$displayName is $status";

    if (facility.description != null && facility.description!.isNotEmpty) {
      text += " (${facility.description})";
    }

    return text;
  }
}
