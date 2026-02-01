import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/features/nearby_mosques/domain/models/mosque.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NearbyMosqueWidget extends StatelessWidget {
  final Mosque? mosque;
  final bool isLoading;

  const NearbyMosqueWidget({
    super.key,
    required this.mosque,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nearby Mosque",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: isLoading
              ? _buildLoadingState()
              : (mosque != null
                  ? _buildMosqueInfo(context, mosque!)
                  : _buildNoMosqueFound(context)),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNoMosqueFound(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_off,
          size: 40,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Text(
          "No nearby mosque found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Try searching for mosques in your area",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        InkWellView(
          onTap: () {
            context.pushNamed(Routes.mosque.name);
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Find Mosques",
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMosqueInfo(BuildContext context, Mosque mosque) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mosque.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                mosque.address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.directions_walk,
              size: 16,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(width: 4),
            Text(
              "${mosque.distance.toStringAsFixed(2)} ${mosque.unit} away",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWellView(
                onTap: () {
                  context.pushNamed(Routes.mosque.name);
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWellView(
                onTap: () => _openDirections(mosque),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions,
                        color: Color(0xFF2196F3),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Directions",
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openDirections(Mosque mosque) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}';
    
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
