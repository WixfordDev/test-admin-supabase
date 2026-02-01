import 'package:flutter/material.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/features/nearby_mosques/data/models/mosque_facility.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';

class EditMosqueFacilitiesBottomSheet extends StatefulWidget {
  final String mosqueId;
  final String mosqueName;
  final double? latitude;
  final double? longitude;
  final String? address;

  const EditMosqueFacilitiesBottomSheet({
    super.key,
    required this.mosqueId,
    required this.mosqueName,
    this.latitude,
    this.longitude,
    this.address,
  });

  @override
  State<EditMosqueFacilitiesBottomSheet> createState() => _EditMosqueFacilitiesBottomSheetState();
}

class _EditMosqueFacilitiesBottomSheetState extends State<EditMosqueFacilitiesBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _mosqueRepository = getIt<MosqueRepository>();
  
  Map<FacilityType, FacilityAvailability> _facilities = {};
  Map<FacilityType, String> _descriptions = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExistingFacilities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingFacilities() async {
    try {
      final facilities = await _mosqueRepository.getMosqueFacilities(widget.mosqueId);
      
      setState(() {
        // Set default values for all facility types first
        _setDefaultFacilities();
        
        // Then override with existing values from database
        for (final facility in facilities) {
          _facilities[facility.facilityType] = facility.availability;
          if (facility.description != null && facility.description!.isNotEmpty) {
            _descriptions[facility.facilityType] = facility.description!;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading facilities: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setDefaultFacilities() {
    // Set default values for specific facilities
    for (final facilityType in FacilityType.values) {
      switch (facilityType) {
        case FacilityType.toilets:
        case FacilityType.wudu:
          _facilities[facilityType] = FacilityAvailability.available;
          break;
        case FacilityType.parking:
          _facilities[facilityType] = FacilityAvailability.unknown;
          break;
        default:
          _facilities[facilityType] = FacilityAvailability.unknown;
          break;
      }
    }
  }

  Future<void> _saveFacilities() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final facilitiesToSave = <MosqueFacility>[];
      
      _facilities.forEach((facilityType, availability) {
        facilitiesToSave.add(MosqueFacility(
          mosqueId: widget.mosqueId,
          facilityType: facilityType,
          availability: availability,
          description: _descriptions[facilityType],
          lastUpdated: DateTime.now(),
          updatedBy: 'community_user', // In a real app, you'd use the actual user ID
        ));
      });

      await _mosqueRepository.saveMosqueFacilities(
        facilitiesToSave,
        updatedBy: 'community_user',
        mosqueName: widget.mosqueName,
        latitude: widget.latitude,
        longitude: widget.longitude,
        address: widget.address,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate successful save
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Facilities updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving facilities: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _BottomSheetHeader(
            mosqueName: widget.mosqueName,
            onClose: () => Navigator.of(context).pop(),
          ),
          _FacilitiesTabBar(tabController: _tabController),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _FacilitiesTabView(
                tabController: _tabController,
                facilities: _facilities,
                descriptions: _descriptions,
                onFacilityChanged: (facilityType, availability) {
                  setState(() {
                    _facilities[facilityType] = availability;
                  });
                },
                onDescriptionChanged: (facilityType, description) {
                  setState(() {
                    if (description.trim().isEmpty) {
                      _descriptions.remove(facilityType);
                    } else {
                      _descriptions[facilityType] = description.trim();
                    }
                  });
                },
              ),
            ),
          _SaveButton(
            isSaving: _isSaving,
            onSave: _saveFacilities,
          ),
        ],
      ),
    );
  }
}

// Separate stateless widgets for better performance
class _BottomSheetHeader extends StatelessWidget {
  final String mosqueName;
  final VoidCallback onClose;

  const _BottomSheetHeader({
    required this.mosqueName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Edit Facilities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).expanded(),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Text(
            mosqueName,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesTabBar extends StatelessWidget {
  final TabController tabController;

  const _FacilitiesTabBar({
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: Colors.black,
      indicatorColor: context.primaryColor,
      tabs: const [
        Tab(text: "General"),
        Tab(text: "For Women"),
        Tab(text: "Accessibility"),
      ],
    );
  }
}

class _FacilitiesTabView extends StatelessWidget {
  final TabController tabController;
  final Map<FacilityType, FacilityAvailability> facilities;
  final Map<FacilityType, String> descriptions;
  final Function(FacilityType, FacilityAvailability) onFacilityChanged;
  final Function(FacilityType, String) onDescriptionChanged;

  const _FacilitiesTabView({
    required this.tabController,
    required this.facilities,
    required this.descriptions,
    required this.onFacilityChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        _FacilitiesTab(
          category: 'General',
          facilities: facilities,
          descriptions: descriptions,
          onFacilityChanged: onFacilityChanged,
          onDescriptionChanged: onDescriptionChanged,
        ),
        _FacilitiesTab(
          category: 'For Women',
          facilities: facilities,
          descriptions: descriptions,
          onFacilityChanged: onFacilityChanged,
          onDescriptionChanged: onDescriptionChanged,
        ),
        _FacilitiesTab(
          category: 'Accessibility',
          facilities: facilities,
          descriptions: descriptions,
          onFacilityChanged: onFacilityChanged,
          onDescriptionChanged: onDescriptionChanged,
        ),
      ],
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  final String category;
  final Map<FacilityType, FacilityAvailability> facilities;
  final Map<FacilityType, String> descriptions;
  final Function(FacilityType, FacilityAvailability) onFacilityChanged;
  final Function(FacilityType, String) onDescriptionChanged;

  const _FacilitiesTab({
    required this.category,
    required this.facilities,
    required this.descriptions,
    required this.onFacilityChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final facilitiesInCategory = FacilityType.values
        .where((facility) => facility.category == category)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facilitiesInCategory.length,
      itemBuilder: (context, index) {
        final facilityType = facilitiesInCategory[index];
        return _FacilityItem(
          facilityType: facilityType,
          currentAvailability: facilities[facilityType] ?? FacilityAvailability.unknown,
          currentDescription: descriptions[facilityType] ?? '',
          onAvailabilityChanged: (availability) => onFacilityChanged(facilityType, availability),
          onDescriptionChanged: (description) => onDescriptionChanged(facilityType, description),
        );
      },
    );
  }
}

class _FacilityItem extends StatelessWidget {
  final FacilityType facilityType;
  final FacilityAvailability currentAvailability;
  final String currentDescription;
  final Function(FacilityAvailability) onAvailabilityChanged;
  final Function(String) onDescriptionChanged;

  const _FacilityItem({
    required this.facilityType,
    required this.currentAvailability,
    required this.currentDescription,
    required this.onAvailabilityChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              facilityType.displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            gapH8,
            _AvailabilityDropdown(
              currentAvailability: currentAvailability,
              onChanged: onAvailabilityChanged,
            ),
            gapH12,
            _DescriptionField(
              currentDescription: currentDescription,
              onChanged: onDescriptionChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityDropdown extends StatelessWidget {
  final FacilityAvailability currentAvailability;
  final Function(FacilityAvailability) onChanged;

  const _AvailabilityDropdown({
    required this.currentAvailability,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FacilityAvailability>(
      value: currentAvailability,
      decoration: const InputDecoration(
        labelText: "Availability Status",
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: FacilityAvailability.values.map((availability) {
        return DropdownMenuItem(
          value: availability,
          child: Text(availability.displayText),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final String currentDescription;
  final Function(String) onChanged;

  const _DescriptionField({
    required this.currentDescription,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: currentDescription,
      decoration: const InputDecoration(
        labelText: "Additional Information (Optional)",
        hintText: "Enter any additional details...",
        border: OutlineInputBorder(),
        isDense: true,
      ),
      maxLines: 2,
      onChanged: onChanged,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveButton({
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
} 