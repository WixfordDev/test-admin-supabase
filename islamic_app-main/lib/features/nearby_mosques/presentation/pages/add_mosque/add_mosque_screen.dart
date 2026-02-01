// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:deenhub/config/routes/routes.dart';
// import 'package:deenhub/config/themes/styles.dart';
// import 'package:deenhub/core/di/app_injections.dart';
// import 'package:deenhub/core/utils/view_utils.dart';
// import 'package:deenhub/core/widgets/edit_text/input_edit_text.dart';
// import 'package:deenhub/features/nearby_mosques/data/repositories/mosque_notification_repository.dart';
// import 'package:deenhub/features/nearby_mosques/data/services/supabase_mosque_service.dart';
// import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
// import 'package:deenhub/main.dart';
// import 'package:deenhub/map_location_picker/map_location_picker.dart';
// import 'package:deenhub/common/prayers/prayer_times_helper.dart';
// import 'package:deenhub/core/services/shared_prefs_helper.dart';
// import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';

// class AddMosqueScreen extends StatefulWidget {
//   const AddMosqueScreen({super.key});

//   @override
//   _AddMosqueScreenState createState() => _AddMosqueScreenState();
// }

// class _AddMosqueScreenState extends State<AddMosqueScreen> {
//   LatLng? latLng;
//   bool _isSubmitting = false;
//   bool _isInitializing = true;

//   // Controllers for the text fields
//   final TextEditingController _mosqueNameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _websiteController = TextEditingController();
//   final TextEditingController _additionalInfoController =
//       TextEditingController();

//   // Controllers for prayer times with separate hour and minute controllers
//   final Map<String, Map<String, Map<String, TextEditingController>>>
//   _prayerTimeControllers = {
//     'Fajr': {
//       'adhan': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//       'iqamah': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//     },
//     'Dhuhr': {
//       'adhan': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//       'iqamah': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//     },
//     'Asr': {
//       'adhan': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//       'iqamah': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//     },
//     'Maghrib': {
//       'adhan': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//       'iqamah': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//     },
//     'Isha': {
//       'adhan': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//       'iqamah': {
//         'hour': TextEditingController(text: "--"),
//         'minute': TextEditingController(text: "--"),
//       },
//     },
//   };

//   @override
//   void initState() {
//     super.initState();
//     _prefillLocationAndPrayerTimes();
//   }

//   // Future<void> _prefillLocationAndPrayerTimes() async {
//   //   try {
//   //     final SharedPrefsHelper sharedPrefsHelper = getIt<SharedPrefsHelper>();
//   //     final currentPrayerData = sharedPrefsHelper.prayerLocationData;

//   //     if (currentPrayerData != null) {
//   //       // Prefill address with current location
//   //       latLng = LatLng(currentPrayerData.lat, currentPrayerData.lng);
//   //       _addressController.text = currentPrayerData.locName;

//   //       // Calculate prayer times for current location
//   //       final tempLocData = PrayerTimesHelper.getPrayerTimings(
//   //         currentPrayerData.toLocationData(),
//   //         currentPrayerData,
//   //         time: DateTime.now(),
//   //       );

//   //       final prayerTimes = tempLocData.prayerTimes ?? [];

//   //       // Prefill prayer times
//   //       for (final prayer in prayerTimes) {
//   //         final prayerName = _getPrayerNameForControllers(prayer.type.name);
//   //         if (_prayerTimeControllers.containsKey(prayerName)) {
//   //           final hour = prayer.time.hour.toString().padLeft(2, '0');
//   //           final minute = prayer.time.minute.toString().padLeft(2, '0');

//   //           _prayerTimeControllers[prayerName]!['adhan']!['hour']!.text = hour;
//   //           _prayerTimeControllers[prayerName]!['adhan']!['minute']!.text = minute;

//   //           // Set iqamah time 10 minutes after adhan for most prayers
//   //           DateTime iqamahTime;
//   //           if (prayerName == 'Maghrib') {
//   //             // Maghrib iqamah is typically 3 minutes after adhan
//   //             iqamahTime = prayer.time.add(const Duration(minutes: 3));
//   //           } else {
//   //             // Other prayers typically 10 minutes after adhan
//   //             iqamahTime = prayer.time.add(const Duration(minutes: 10));
//   //           }

//   //           final iqamahHour = iqamahTime.hour.toString().padLeft(2, '0');
//   //           final iqamahMinute = iqamahTime.minute.toString().padLeft(2, '0');

//   //           _prayerTimeControllers[prayerName]!['iqamah']!['hour']!.text = iqamahHour;
//   //           _prayerTimeControllers[prayerName]!['iqamah']!['minute']!.text = iqamahMinute;
//   //         }
//   //       }

//   //       logger.d('Prefilled location: ${currentPrayerData.locName}');
//   //       logger.d('Prefilled ${prayerTimes.length} prayer times');
//   //     }
//   //   } catch (e) {
//   //     logger.e('Error prefilling location and prayer times: $e');
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         _isInitializing = false;
//   //       });
//   //     }
//   //   }
//   // }

//   Future<void> _prefillLocationAndPrayerTimes() async {
//     try {
//       final SharedPrefsHelper sharedPrefsHelper = getIt<SharedPrefsHelper>();
//       final currentPrayerData = sharedPrefsHelper.prayerLocationData;

//       if (currentPrayerData != null) {
//         // Prefill address with current location
//         latLng = LatLng(currentPrayerData.lat, currentPrayerData.lng);
//         _addressController.text = currentPrayerData.locName;

//         // Calculate prayer times for MOSQUE location (not user location)
//         // This is important for USA mosques when user is in Bangladesh
//         final mosqueLocationData = currentPrayerData.copyWith(
//           lat: latLng!.latitude,
//           lng: latLng!.longitude,
//           locName: _addressController.text,
//         );

//         final tempLocData = PrayerTimesHelper.getPrayerTimings(
//           mosqueLocationData.toLocationData(),
//           mosqueLocationData,
//           time: DateTime.now(), // Use UTC or mosque's timezone
//         );

//         final prayerTimes = tempLocData.prayerTimes ?? [];

//         // Prefill prayer times
//         for (final prayer in prayerTimes) {
//           final prayerName = _getPrayerNameForControllers(prayer.type.name);
//           if (_prayerTimeControllers.containsKey(prayerName)) {
//             // Use the prayer's actual time (which is in the correct timezone)
//             final hour = prayer.time.hour.toString().padLeft(2, '0');
//             final minute = prayer.time.minute.toString().padLeft(2, '0');

//             _prayerTimeControllers[prayerName]!['adhan']!['hour']!.text = hour;
//             _prayerTimeControllers[prayerName]!['adhan']!['minute']!.text =
//                 minute;

//             // Set iqamah time based on prayer type
//             DateTime iqamahTime;
//             if (prayerName == 'Maghrib') {
//               iqamahTime = prayer.time.add(const Duration(minutes: 3));
//             } else {
//               iqamahTime = prayer.time.add(const Duration(minutes: 10));
//             }

//             final iqamahHour = iqamahTime.hour.toString().padLeft(2, '0');
//             final iqamahMinute = iqamahTime.minute.toString().padLeft(2, '0');

//             _prayerTimeControllers[prayerName]!['iqamah']!['hour']!.text =
//                 iqamahHour;
//             _prayerTimeControllers[prayerName]!['iqamah']!['minute']!.text =
//                 iqamahMinute;
//           }
//         }

//         logger.d('Prefilled location: ${currentPrayerData.locName}');
//         logger.d('Prefilled ${prayerTimes.length} prayer times');
//       }
//     } catch (e) {
//       logger.e('Error prefilling location and prayer times: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isInitializing = false;
//         });
//       }
//     }
//   }

//   String _getPrayerNameForControllers(String prayerTypeName) {
//     switch (prayerTypeName.toLowerCase()) {
//       case 'fajr':
//         return 'Fajr';
//       case 'dhuhr':
//         return 'Dhuhr';
//       case 'asr':
//         return 'Asr';
//       case 'maghrib':
//         return 'Maghrib';
//       case 'isha':
//         return 'Isha';
//       default:
//         return prayerTypeName;
//     }
//   }

//   @override
//   void dispose() {
//     _mosqueNameController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     _websiteController.dispose();
//     _additionalInfoController.dispose();

//     // Dispose prayer time controllers
//     _prayerTimeControllers.forEach((prayer, types) {
//       types.forEach((type, controllers) {
//         controllers.forEach((field, controller) {
//           controller.dispose();
//         });
//       });
//     });

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add a New Mosque'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             context.pop();
//           },
//         ),
//       ),
//       body: _isInitializing
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading location and prayer times...'),
//                 ],
//               ),
//             )
//           : SafeArea(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _MosqueInfoSection(
//                       mosqueNameController: _mosqueNameController,
//                       addressController: _addressController,
//                       phoneController: _phoneController,
//                       websiteController: _websiteController,
//                       additionalInfoController: _additionalInfoController,
//                       latLng: latLng,
//                       onLocationSelected: (selectedLatLng, address) {
//                         setState(() {
//                           latLng = selectedLatLng;
//                           _addressController.text = address;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _PrayerTimesSection(
//                       prayerTimeControllers: _prayerTimeControllers,
//                     ),
//                     const SizedBox(height: 16),
//                     const _RequiredFieldsNote(),
//                     const SizedBox(height: 24),
//                     _ActionButtons(
//                       isSubmitting: _isSubmitting,
//                       onCancel: () => context.pop(),
//                       onSubmit: _addMosque,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Future<void> _addMosque() async {
//     // Validate required fields
//     if (_mosqueNameController.text.trim().isEmpty) {
//       _showErrorSnackBar('Please enter a mosque name');
//       return;
//     }

//     if (_addressController.text.trim().isEmpty || latLng == null) {
//       _showErrorSnackBar('Please select a location');
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       final mosqueNotificationRepository =
//           getIt<MosqueNotificationRepository>();
//       final mosqueService = getIt<SupabaseMosqueService>();

//       // Generate a unique mosque ID (you might want to use a better approach)
//       final mosqueId = 'user_mosque_${DateTime.now().millisecondsSinceEpoch}';

//       // First, save the mosque metadata to the database
//       await mosqueService.saveMosqueMetadata(
//         mosqueId: mosqueId,
//         name: _mosqueNameController.text.trim(),
//         latitude: latLng!.latitude,
//         longitude: latLng!.longitude,
//         address: _addressController.text.trim(),
//         phone: _phoneController.text.trim().isNotEmpty
//             ? _phoneController.text.trim()
//             : null,
//         website: _websiteController.text.trim().isNotEmpty
//             ? _websiteController.text.trim()
//             : null,
//         additionalInfo: _additionalInfoController.text.trim().isNotEmpty
//             ? _additionalInfoController.text.trim()
//             : null,
//       );

//       // Calculate prayer times for the mosque location to get base times for comparison
//       final SharedPrefsHelper sharedPrefsHelper = getIt<SharedPrefsHelper>();
//       final currentPrayerData = sharedPrefsHelper.prayerLocationData;

//       // Create temporary location data for this mosque location
//       final tempLocationData = currentPrayerData.copyWith(
//         lat: latLng!.latitude,
//         lng: latLng!.longitude,
//         locName: _addressController.text,
//       );

//       // Calculate the base prayer times for this location
//       final tempLocData = PrayerTimesHelper.getPrayerTimings(
//         tempLocationData.toLocationData(),
//         tempLocationData,
//         time: DateTime.now(),
//       );

//       final basePrayerTimes = tempLocData.prayerTimes ?? [];

//       // Log available prayer times
//       logger.d(
//         'Available calculated prayer times for mosque: ${_mosqueNameController.text}',
//       );
//       for (final prayer in basePrayerTimes) {
//         logger.d('  ${prayer.type.name.toLowerCase()}: ${prayer.time}');
//       }

//       // Collect prayer time adjustments and save them
//       final Map<String, int> prayerAdjustments = {};

//       for (final entry in _prayerTimeControllers.entries) {
//         final prayerName = entry.key.toLowerCase();
//         final controllers = entry.value;

//         // Handle adhan times
//         final adhanHourText = controllers['adhan']!['hour']!.text;
//         final adhanMinuteText = controllers['adhan']!['minute']!.text;

//         if (adhanHourText.isNotEmpty &&
//             adhanMinuteText.isNotEmpty &&
//             adhanHourText != '--' &&
//             adhanMinuteText != '--') {
//           final hour = int.tryParse(adhanHourText) ?? 0;
//           final minute = int.tryParse(adhanMinuteText) ?? 0;

//           try {
//             // Find the corresponding prayer in calculated times
//             final prayerEntry = basePrayerTimes.firstWhere(
//               (prayer) => prayer.type.name.toLowerCase() == prayerName,
//               orElse: () {
//                 logger.e(
//                   'Adhan: Prayer $prayerName not found in calculated times. Available prayers: ${basePrayerTimes.map((p) => p.type.name.toLowerCase()).join(', ')}',
//                 );
//                 // If the prayer is not found, throw a special exception that we can catch
//                 throw StateError(
//                   'Prayer $prayerName not found in calculated times',
//                 );
//               },
//             );

//             // Create the user-entered prayer time in the same timezone as calculated prayer time
//             final calculatedTime = prayerEntry.time;
//             final userEnteredTime = DateTime(
//               calculatedTime.year,
//               calculatedTime.month,
//               calculatedTime.day,
//               hour,
//               minute,
//             );

//             // Calculate the adjustment in minutes
//             final adjustmentMinutes = userEnteredTime
//                 .difference(calculatedTime)
//                 .inMinutes;

//             // Always save the adjustment, even if it's 0 (which means user confirmed the calculated time)
//             prayerAdjustments['${prayerName}_adhan'] = adjustmentMinutes;

//             // Save individual prayer time adjustments to Supabase
//             await mosqueNotificationRepository.updateMosquePrayerTime(
//               mosqueId: mosqueId,
//               mosqueName: _mosqueNameController.text.trim(),
//               mosqueLatitude: latLng!.latitude,
//               mosqueLongitude: latLng!.longitude,
//               prayerName: prayerName,
//               timeType: 'adhan',
//               adjustmentMinutes: adjustmentMinutes,
//               onMosqueAdjustmentUpdated: (mosqueId) {
//                 // Clear the cache for this mosque in the mosque repository
//                 final mosqueRepository = getIt<MosqueRepository>();
//                 mosqueRepository.clearCacheForMosque(mosqueId);
//               },
//             );
//           } catch (e) {
//             logger.w(
//               'Skipping adhan time for $prayerName as it was not found in calculated times: $e',
//             );
//             // Continue to the next prayer, or skip to iqamah for this prayer
//           }
//         }

//         // Handle iqamah times
//         final iqamahHourText = controllers['iqamah']!['hour']!.text;
//         final iqamahMinuteText = controllers['iqamah']!['minute']!.text;

//         if (iqamahHourText.isNotEmpty &&
//             iqamahMinuteText.isNotEmpty &&
//             iqamahHourText != '--' &&
//             iqamahMinuteText != '--') {
//           final hour = int.tryParse(iqamahHourText) ?? 0;
//           final minute = int.tryParse(iqamahMinuteText) ?? 0;

//           try {
//             // Find the corresponding prayer in calculated times
//             final prayerEntry = basePrayerTimes.firstWhere(
//               (prayer) => prayer.type.name.toLowerCase() == prayerName,
//               orElse: () {
//                 logger.e(
//                   'Iqamah: Prayer $prayerName not found in calculated times. Available prayers: ${basePrayerTimes.map((p) => p.type.name.toLowerCase()).join(', ')}',
//                 );
//                 // If the prayer is not found, throw a special exception that we can catch
//                 throw StateError(
//                   'Prayer $prayerName not found in calculated times',
//                 );
//               },
//             );

//             // Create the user-entered iqamah time in the same timezone as calculated prayer time
//             final calculatedTime = prayerEntry.time;
//             final userEnteredIqamahTime = DateTime(
//               calculatedTime.year,
//               calculatedTime.month,
//               calculatedTime.day,
//               hour,
//               minute,
//             );

//             // For iqamah, we calculate adjustment from the adhan time (not the calculated time)
//             // If there's an adhan adjustment, apply it first
//             final adhanAdjustmentKey = '${prayerName}_adhan';
//             final adhanAdjustment = prayerAdjustments[adhanAdjustmentKey] ?? 0;
//             final adjustedAdhanTime = calculatedTime.add(
//               Duration(minutes: adhanAdjustment),
//             );

//             // Calculate the iqamah adjustment from the adjusted adhan time
//             final iqamahAdjustmentMinutes = userEnteredIqamahTime
//                 .difference(adjustedAdhanTime)
//                 .inMinutes;

//             // Always save the adjustment, even if it's 0
//             prayerAdjustments['${prayerName}_iqamah'] = iqamahAdjustmentMinutes;

//             // Save individual iqamah time adjustments to Supabase
//             await mosqueNotificationRepository.updateMosquePrayerTime(
//               mosqueId: mosqueId,
//               mosqueName: _mosqueNameController.text.trim(),
//               mosqueLatitude: latLng!.latitude,
//               mosqueLongitude: latLng!.longitude,
//               prayerName: prayerName,
//               timeType: 'iqamah',
//               adjustmentMinutes: iqamahAdjustmentMinutes,
//               onMosqueAdjustmentUpdated: (mosqueId) {
//                 // Clear the cache for this mosque in the mosque repository
//                 final mosqueRepository = getIt<MosqueRepository>();
//                 mosqueRepository.clearCacheForMosque(mosqueId);
//               },
//             );
//           } catch (e) {
//             logger.w(
//               'Skipping iqamah time for $prayerName as it was not found in calculated times: $e',
//             );
//             // Continue to the next prayer
//           }
//         }
//       }

//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Mosque added successfully! ${prayerAdjustments.length} prayer time adjustments saved.',
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );

//         // Navigate back
//         context.pop();
//       }
//     } catch (e) {
//       logger.e('Error adding mosque: $e');
//       _showErrorSnackBar('Failed to add mosque: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//         });
//       }
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
// }

// // Separate stateless widgets for better performance
// class _MosqueInfoSection extends StatelessWidget {
//   final TextEditingController mosqueNameController;
//   final TextEditingController addressController;
//   final TextEditingController phoneController;
//   final TextEditingController websiteController;
//   final TextEditingController additionalInfoController;
//   final LatLng? latLng;
//   final Function(LatLng, String) onLocationSelected;

//   const _MosqueInfoSection({
//     required this.mosqueNameController,
//     required this.addressController,
//     required this.phoneController,
//     required this.websiteController,
//     required this.additionalInfoController,
//     required this.latLng,
//     required this.onLocationSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Mosque Information',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           'Please provide details about the mosque you would like to add to our database. This helps the community find accurate information about local mosques.',
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//         const SizedBox(height: 24),
//         _FormField(
//           icon: Icons.mosque,
//           label: 'Mosque Name',
//           isRequired: true,
//           child: InputEditText(
//             controller: mosqueNameController,
//             hint: 'Enter the name of the mosque',
//             inputType: TextInputType.text,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _FormField(
//           icon: Icons.location_on,
//           label: 'Address',
//           isRequired: true,
//           child: _AddressField(
//             controller: addressController,
//             latLng: latLng,
//             onLocationSelected: onLocationSelected,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _ContactInfoRow(
//           phoneController: phoneController,
//           websiteController: websiteController,
//         ),
//         const SizedBox(height: 16),
//         _FormField(
//           label: 'Additional Information (optional)',
//           child: InputEditText(
//             controller: additionalInfoController,
//             hint: 'Add any useful information about the mosque',
//             maxLines: 4,
//             inputType: TextInputType.multiline,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _FormField extends StatelessWidget {
//   final IconData? icon;
//   final String label;
//   final bool isRequired;
//   final Widget child;

//   const _FormField({
//     this.icon,
//     required this.label,
//     this.isRequired = false,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             if (icon != null) ...[
//               Icon(icon, color: Colors.grey),
//               const SizedBox(width: 8),
//             ],
//             Text(label, style: const TextStyle(fontSize: 16)),
//             if (isRequired)
//               const Text('*', style: TextStyle(color: Colors.red)),
//           ],
//         ),
//         const SizedBox(height: 8),
//         child,
//       ],
//     );
//   }
// }

// class _AddressField extends StatelessWidget {
//   final TextEditingController controller;
//   final LatLng? latLng;
//   final Function(LatLng, String) onLocationSelected;

//   const _AddressField({
//     required this.controller,
//     required this.latLng,
//     required this.onLocationSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InputEditText(
//       controller: controller,
//       inputType: TextInputType.streetAddress,
//       readOnly: true,
//       hint: 'Street address, city, state, zip',
//       onTap: () async {
//         final result = await context.pushNamed<GeocodingResult?>(
//           Routes.mapsLocationPicker.name,
//           queryParameters: {
//             "lat": (latLng?.latitude).toString(),
//             "lng": (latLng?.longitude).toString(),
//           },
//         );

//         if (result != null) {
//           final selectedLatLng = LatLng(
//             result.geometry.location.lat,
//             result.geometry.location.lng,
//           );
//           final locName =
//               result.formattedAddress ??
//               '${result.geometry.location.lat}, ${result.geometry.location.lng}';
//           onLocationSelected(selectedLatLng, locName);
//           logger.d('Selected Location: $locName');
//         }
//       },
//     );
//   }
// }

// class _ContactInfoRow extends StatelessWidget {
//   final TextEditingController phoneController;
//   final TextEditingController websiteController;

//   const _ContactInfoRow({
//     required this.phoneController,
//     required this.websiteController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.phone, color: Colors.grey),
//             gapW8,
//             const Text(
//               'Phone (optional)',
//               style: TextStyle(fontSize: 16),
//             ).expanded(),
//             gapW16,
//             Text(
//               'Website (optional)',
//               style: TextStyle(fontSize: 16),
//             ).expanded(),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             InputEditText(
//               controller: phoneController,
//               hint: 'Phone number',
//               inputType: TextInputType.number,
//             ).expanded(),
//             gapW16,
//             InputEditText(
//               controller: websiteController,
//               hint: 'Website URL',
//               inputType: TextInputType.url,
//             ).expanded(),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _PrayerTimesSection extends StatelessWidget {
//   final Map<String, Map<String, Map<String, TextEditingController>>>
//   prayerTimeControllers;

//   const _PrayerTimesSection({required this.prayerTimeControllers});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.access_time, color: Colors.grey),
//             const SizedBox(width: 8),
//             const Text(
//               'Prayer Times (if known)',
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           'The times below are calculated for your location. Please adjust them to match the actual mosque timings.',
//           style: TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         const SizedBox(height: 16),
//         _PrayerTimesTable(prayerTimeControllers: prayerTimeControllers),
//       ],
//     );
//   }
// }

// class _PrayerTimesTable extends StatelessWidget {
//   final Map<String, Map<String, Map<String, TextEditingController>>>
//   prayerTimeControllers;

//   const _PrayerTimesTable({required this.prayerTimeControllers});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Table Header
//         Row(
//           children: [
//             const Expanded(
//               flex: 2,
//               child: Text(
//                 'Prayer',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             Expanded(
//               flex: 4,
//               child: Container(
//                 alignment: Alignment.center,
//                 child: const Text(
//                   'Adhan Time',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 4,
//               child: Container(
//                 alignment: Alignment.center,
//                 child: const Text(
//                   'Iqamah Time',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         // Prayer Time Rows
//         ...prayerTimeControllers.entries.map((entry) {
//           final prayerName = entry.key;
//           final timeTypes = entry.value;

//           return _PrayerTimeRow(
//             prayerName: prayerName,
//             adhanHourController: timeTypes['adhan']!['hour']!,
//             adhanMinuteController: timeTypes['adhan']!['minute']!,
//             iqamahHourController: timeTypes['iqamah']!['hour']!,
//             iqamahMinuteController: timeTypes['iqamah']!['minute']!,
//           );
//         }),
//       ],
//     );
//   }
// }

// class _PrayerTimeRow extends StatelessWidget {
//   final String prayerName;
//   final TextEditingController adhanHourController;
//   final TextEditingController adhanMinuteController;
//   final TextEditingController iqamahHourController;
//   final TextEditingController iqamahMinuteController;

//   const _PrayerTimeRow({
//     required this.prayerName,
//     required this.adhanHourController,
//     required this.adhanMinuteController,
//     required this.iqamahHourController,
//     required this.iqamahMinuteController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Prayer name column
//           Expanded(flex: 2, child: Text(prayerName)),
//           // Adhan time column
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: _SplitTimeField(
//                 hourController: adhanHourController,
//                 minuteController: adhanMinuteController,
//               ),
//             ),
//           ),
//           // Iqamah time column
//           Expanded(
//             flex: 4,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: _SplitTimeField(
//                 hourController: iqamahHourController,
//                 minuteController: iqamahMinuteController,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SplitTimeField extends StatelessWidget {
//   final TextEditingController hourController;
//   final TextEditingController minuteController;

//   const _SplitTimeField({
//     required this.hourController,
//     required this.minuteController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Row(
//         children: [
//           // Hour field
//           _TimeFormField(controller: hourController, isHour: true).expanded(),
//           // Colon separator
//           const Text(
//             ':',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           // Minute field
//           _TimeFormField(
//             controller: minuteController,
//             isHour: false,
//           ).expanded(),
//           // Clock icon
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Icon(Icons.access_time, color: Colors.grey[600], size: 20),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TimeFormField extends StatelessWidget {
//   final TextEditingController controller;
//   final bool isHour;

//   const _TimeFormField({required this.controller, required this.isHour});

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       textAlign: TextAlign.center,
//       keyboardType: TextInputType.number,
//       inputFormatters: [
//         FilteringTextInputFormatter.digitsOnly,
//         LengthLimitingTextInputFormatter(2),
//         isHour ? HourInputFormatter() : MinuteInputFormatter(),
//       ],
//       decoration: const InputDecoration(
//         border: InputBorder.none,
//         contentPadding: EdgeInsets.symmetric(vertical: 12),
//       ),
//     );
//   }
// }

// class _RequiredFieldsNote extends StatelessWidget {
//   const _RequiredFieldsNote();

//   @override
//   Widget build(BuildContext context) {
//     return const Text(
//       '*Required fields',
//       style: TextStyle(color: Colors.grey, fontSize: 14),
//     );
//   }
// }

// class _ActionButtons extends StatelessWidget {
//   final bool isSubmitting;
//   final VoidCallback onCancel;
//   final VoidCallback onSubmit;

//   const _ActionButtons({
//     required this.isSubmitting,
//     required this.onCancel,
//     required this.onSubmit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         OutlinedButton(
//           onPressed: onCancel,
//           style: OutlinedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: isSubmitting ? null : onSubmit,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: context.primaryColor,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: isSubmitting
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 )
//               : const Text('Add Mosque', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }

// class HourInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     String text = newValue.text;

//     // Clear default "--" when user starts typing
//     if (oldValue.text == "--" && text.isNotEmpty && text != "--") {
//       text = text.replaceAll(RegExp(r'[^0-9]'), '');
//     }

//     if (text.isEmpty) return newValue.copyWith(text: ""); // Allow empty input

//     int? value = int.tryParse(text);

//     if (value == null || value < 0 || value > 23) {
//       return oldValue; // Reject invalid input
//     }

//     return newValue.copyWith(text: text);
//   }
// }

// class MinuteInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     String text = newValue.text;

//     // Clear default "--" when user starts typing
//     if (oldValue.text == "--" && text.isNotEmpty && text != "--") {
//       text = text.replaceAll(RegExp(r'[^0-9]'), '');
//     }

//     if (text.isEmpty) return newValue.copyWith(text: ""); // Allow empty input

//     int? value = int.tryParse(text);

//     if (value == null || value < 0 || value > 59) {
//       return oldValue; // Reject invalid input
//     }

//     return newValue.copyWith(text: text);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/edit_text/input_edit_text.dart';
import 'package:deenhub/features/nearby_mosques/data/repositories/mosque_notification_repository.dart';
import 'package:deenhub/features/nearby_mosques/data/services/supabase_mosque_service.dart';
import 'package:deenhub/features/nearby_mosques/domain/repositories/mosque_repository.dart';
import 'package:deenhub/main.dart';
import 'package:deenhub/map_location_picker/map_location_picker.dart';
import 'package:deenhub/common/prayers/prayer_times_helper.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/features/prayers/domain/model/prayer_location_data.dart';
import 'package:timezone/timezone.dart' as tz;

class AddMosqueScreen extends StatefulWidget {
  const AddMosqueScreen({super.key});

  @override
  _AddMosqueScreenState createState() => _AddMosqueScreenState();
}

class _AddMosqueScreenState extends State<AddMosqueScreen> {
  LatLng? latLng;
  bool _isSubmitting = false;
  bool _isInitializing = true;
  String? _mosqueTimezone; // Store the mosque's timezone

  // Controllers for the text fields
  final TextEditingController _mosqueNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  // Controllers for prayer times with separate hour and minute controllers
  final Map<String, Map<String, Map<String, TextEditingController>>>
  _prayerTimeControllers = {
    'Fajr': {
      'adhan': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
      'iqamah': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
    },
    'Dhuhr': {
      'adhan': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
      'iqamah': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
    },
    'Asr': {
      'adhan': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
      'iqamah': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
    },
    'Maghrib': {
      'adhan': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
      'iqamah': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
    },
    'Isha': {
      'adhan': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
      'iqamah': {
        'hour': TextEditingController(text: "--"),
        'minute': TextEditingController(text: "--"),
      },
    },
  };

  @override
  void initState() {
    super.initState();
    print("===============================sagor");
    _prefillLocationAndPrayerTimes();
  }

  // Helper function to get timezone from latitude/longitude
  String _getTimezoneForLocation(double lat, double lng) {
    try {
      // Try to get timezone from coordinates
      // This is a simple approximation - in production you'd use a proper timezone lookup service
      if (lat >= 24.0 && lat <= 26.0 && lng >= -100.0 && lng <= -95.0) {
        return 'America/Chicago'; // Texas area
      } else if (lat >= 40.0 && lat <= 41.0 && lng >= -74.5 && lng <= -73.5) {
        return 'America/New_York'; // New York area
      } else if (lat >= 33.0 && lat <= 34.5 && lng >= -118.5 && lng <= -117.5) {
        return 'America/Los_Angeles'; // LA area
      } else if (lat >= 20.0 && lat <= 26.0 && lng >= 88.0 && lng <= 92.0) {
        return 'Asia/Dhaka'; // Bangladesh
      }

      // Default to UTC if we can't determine
      return 'UTC';
    } catch (e) {
      logger.e('Error determining timezone: $e');
      return 'UTC';
    }
  }

  Future<void> _prefillLocationAndPrayerTimes() async {
    try {
      final SharedPrefsHelper sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final currentPrayerData = sharedPrefsHelper.prayerLocationData;

      if (currentPrayerData != null) {
        // Prefill address with current location
        latLng = LatLng(currentPrayerData.lat, currentPrayerData.lng);
        _addressController.text = currentPrayerData.locName;

        // Get timezone for the selected location
        _mosqueTimezone = _getTimezoneForLocation(
          currentPrayerData.lat,
          currentPrayerData.lng,
        );

        // Create location data for the MOSQUE location (not user location)
        final mosqueLocationData = PrayerLocationData(
          lat: latLng!.latitude,
          lng: latLng!.longitude,
          locName: _addressController.text,
          timezone: _mosqueTimezone!, // Use mosque's timezone
          country: '', // You might want to detect this
          calculationMethod: currentPrayerData.calculationMethod,
          asrMethod: currentPrayerData.asrMethod,
        );

        // Get current time in the MOSQUE's timezone
        final mosqueLocation = tz.getLocation(_mosqueTimezone!);
        final nowInMosqueTimezone = tz.TZDateTime.now(mosqueLocation);

        logger.d('🕌 Mosque Location: ${_addressController.text}');
        logger.d('🌍 Mosque Timezone: $_mosqueTimezone');
        logger.d('⏰ Current time in mosque timezone: $nowInMosqueTimezone');

        // Calculate prayer times for the mosque's location and timezone
        final tempLocData = PrayerTimesHelper.getPrayerTimings(
          mosqueLocationData.toLocationData(),
          mosqueLocationData,
          time: nowInMosqueTimezone, // Use mosque's timezone
        );

        final prayerTimes = tempLocData.prayerTimes ?? [];

        // Prefill prayer times with mosque's local time
        for (final prayer in prayerTimes) {
          final prayerName = _getPrayerNameForControllers(prayer.type.name);
          if (_prayerTimeControllers.containsKey(prayerName)) {
            // Convert to mosque's local time
            final prayerTimeInMosqueTz = tz.TZDateTime.from(
              prayer.time,
              mosqueLocation,
            );

            final hour = prayerTimeInMosqueTz.hour.toString().padLeft(2, '0');
            final minute = prayerTimeInMosqueTz.minute.toString().padLeft(
              2,
              '0',
            );

            logger.d(
              '📿 $prayerName Adhan: $hour:$minute (${_mosqueTimezone})',
            );

            _prayerTimeControllers[prayerName]!['adhan']!['hour']!.text = hour;
            _prayerTimeControllers[prayerName]!['adhan']!['minute']!.text =
                minute;

            // Set iqamah time based on prayer
            DateTime iqamahTime;
            if (prayerName == 'Maghrib') {
              iqamahTime = prayerTimeInMosqueTz.add(const Duration(minutes: 3));
            } else {
              iqamahTime = prayerTimeInMosqueTz.add(
                const Duration(minutes: 10),
              );
            }

            final iqamahHour = iqamahTime.hour.toString().padLeft(2, '0');
            final iqamahMinute = iqamahTime.minute.toString().padLeft(2, '0');

            logger.d(
              '📿 $prayerName Iqamah: $iqamahHour:$iqamahMinute (${_mosqueTimezone})',
            );

            _prayerTimeControllers[prayerName]!['iqamah']!['hour']!.text =
                iqamahHour;
            _prayerTimeControllers[prayerName]!['iqamah']!['minute']!.text =
                iqamahMinute;
          }
        }

        logger.d(
          '✅ Prefilled ${prayerTimes.length} prayer times for $_mosqueTimezone',
        );
      }
    } catch (e) {
      logger.e('❌ Error prefilling location and prayer times: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  String _getPrayerNameForControllers(String prayerTypeName) {
    switch (prayerTypeName.toLowerCase()) {
      case 'fajr':
        return 'Fajr';
      case 'dhuhr':
        return 'Dhuhr';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Maghrib';
      case 'isha':
        return 'Isha';
      default:
        return prayerTypeName;
    }
  }

  @override
  void dispose() {
    _mosqueNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _additionalInfoController.dispose();

    _prayerTimeControllers.forEach((prayer, types) {
      types.forEach((type, controllers) {
        controllers.forEach((field, controller) {
          controller.dispose();
        });
      });
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Mosque'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: _isInitializing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Loading location and prayer times...'),
                  if (_mosqueTimezone != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Timezone: $_mosqueTimezone',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MosqueInfoSection(
                      mosqueNameController: _mosqueNameController,
                      addressController: _addressController,
                      phoneController: _phoneController,
                      websiteController: _websiteController,
                      additionalInfoController: _additionalInfoController,
                      latLng: latLng,
                      mosqueTimezone: _mosqueTimezone,
                      onLocationSelected: (selectedLatLng, address) async {
                        setState(() {
                          latLng = selectedLatLng;
                          _addressController.text = address;
                          _mosqueTimezone = _getTimezoneForLocation(
                            selectedLatLng.latitude,
                            selectedLatLng.longitude,
                          );
                        });

                        // Recalculate prayer times for new location
                        await _prefillLocationAndPrayerTimes();
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_mosqueTimezone != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Timezone: $_mosqueTimezone',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    _PrayerTimesSection(
                      prayerTimeControllers: _prayerTimeControllers,
                      mosqueTimezone: _mosqueTimezone,
                    ),
                    const SizedBox(height: 16),
                    const _RequiredFieldsNote(),
                    const SizedBox(height: 24),
                    _ActionButtons(
                      isSubmitting: _isSubmitting,
                      onCancel: () => context.pop(),
                      onSubmit: _addMosque,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addMosque() async {
    // Validation
    if (_mosqueNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a mosque name');
      return;
    }

    if (_addressController.text.trim().isEmpty || latLng == null) {
      _showErrorSnackBar('Please select a location');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final mosqueNotificationRepository =
          getIt<MosqueNotificationRepository>();
      final mosqueService = getIt<SupabaseMosqueService>();

      final mosqueId = 'user_mosque_${DateTime.now().millisecondsSinceEpoch}';

      // Save mosque metadata
      await mosqueService.saveMosqueMetadata(
        mosqueId: mosqueId,
        name: _mosqueNameController.text.trim(),
        latitude: latLng!.latitude,
        longitude: latLng!.longitude,
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        additionalInfo: _additionalInfoController.text.trim().isNotEmpty
            ? _additionalInfoController.text.trim()
            : null,
      );

      // Calculate base prayer times for the mosque location
      final SharedPrefsHelper sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final currentPrayerData = sharedPrefsHelper.prayerLocationData;

      final mosqueLocationData = PrayerLocationData(
        lat: latLng!.latitude,
        lng: latLng!.longitude,
        locName: _addressController.text,
        timezone: _mosqueTimezone ?? 'UTC',
        country: '',
        calculationMethod: currentPrayerData.calculationMethod,
        asrMethod: currentPrayerData.asrMethod,
      );

      // Get mosque's local time
      final mosqueLocation = tz.getLocation(_mosqueTimezone ?? 'UTC');
      final nowInMosqueTimezone = tz.TZDateTime.now(mosqueLocation);

      final tempLocData = PrayerTimesHelper.getPrayerTimings(
        mosqueLocationData.toLocationData(),
        mosqueLocationData,
        time: nowInMosqueTimezone,
      );

      final basePrayerTimes = tempLocData.prayerTimes ?? [];

      logger.d(
        '💾 Saving prayer adjustments for mosque: ${_mosqueNameController.text}',
      );

      final Map<String, int> prayerAdjustments = {};

      for (final entry in _prayerTimeControllers.entries) {
        final prayerName = entry.key.toLowerCase();
        final controllers = entry.value;

        // Handle adhan times
        final adhanHourText = controllers['adhan']!['hour']!.text;
        final adhanMinuteText = controllers['adhan']!['minute']!.text;

        if (adhanHourText.isNotEmpty &&
            adhanMinuteText.isNotEmpty &&
            adhanHourText != '--' &&
            adhanMinuteText != '--') {
          final hour = int.tryParse(adhanHourText) ?? 0;
          final minute = int.tryParse(adhanMinuteText) ?? 0;

          try {
            final prayerEntry = basePrayerTimes.firstWhere(
              (prayer) => prayer.type.name.toLowerCase() == prayerName,
            );

            // Create times in mosque's timezone
            final calculatedTimeInMosqueTz = tz.TZDateTime.from(
              prayerEntry.time,
              mosqueLocation,
            );

            final userEnteredTime = tz.TZDateTime(
              mosqueLocation,
              calculatedTimeInMosqueTz.year,
              calculatedTimeInMosqueTz.month,
              calculatedTimeInMosqueTz.day,
              hour,
              minute,
            );

            final adjustmentMinutes = userEnteredTime
                .difference(calculatedTimeInMosqueTz)
                .inMinutes;

            logger.d(
              '📿 $prayerName Adhan adjustment: $adjustmentMinutes minutes',
            );

            prayerAdjustments['${prayerName}_adhan'] = adjustmentMinutes;

            await mosqueNotificationRepository.updateMosquePrayerTime(
              mosqueId: mosqueId,
              mosqueName: _mosqueNameController.text.trim(),
              mosqueLatitude: latLng!.latitude,
              mosqueLongitude: latLng!.longitude,
              prayerName: prayerName,
              timeType: 'adhan',
              adjustmentMinutes: adjustmentMinutes,
              onMosqueAdjustmentUpdated: (mosqueId) {
                final mosqueRepository = getIt<MosqueRepository>();
                mosqueRepository.clearCacheForMosque(mosqueId);
              },
            );
          } catch (e) {
            logger.w('⚠️ Skipping adhan time for $prayerName: $e');
          }
        }

        // Handle iqamah times
        final iqamahHourText = controllers['iqamah']!['hour']!.text;
        final iqamahMinuteText = controllers['iqamah']!['minute']!.text;

        if (iqamahHourText.isNotEmpty &&
            iqamahMinuteText.isNotEmpty &&
            iqamahHourText != '--' &&
            iqamahMinuteText != '--') {
          final hour = int.tryParse(iqamahHourText) ?? 0;
          final minute = int.tryParse(iqamahMinuteText) ?? 0;

          try {
            final prayerEntry = basePrayerTimes.firstWhere(
              (prayer) => prayer.type.name.toLowerCase() == prayerName,
            );

            final calculatedTimeInMosqueTz = tz.TZDateTime.from(
              prayerEntry.time,
              mosqueLocation,
            );

            final userEnteredIqamahTime = tz.TZDateTime(
              mosqueLocation,
              calculatedTimeInMosqueTz.year,
              calculatedTimeInMosqueTz.month,
              calculatedTimeInMosqueTz.day,
              hour,
              minute,
            );

            final adhanAdjustmentKey = '${prayerName}_adhan';
            final adhanAdjustment = prayerAdjustments[adhanAdjustmentKey] ?? 0;
            final adjustedAdhanTime = calculatedTimeInMosqueTz.add(
              Duration(minutes: adhanAdjustment),
            );

            final iqamahAdjustmentMinutes = userEnteredIqamahTime
                .difference(adjustedAdhanTime)
                .inMinutes;

            logger.d(
              '📿 $prayerName Iqamah adjustment: $iqamahAdjustmentMinutes minutes',
            );

            prayerAdjustments['${prayerName}_iqamah'] = iqamahAdjustmentMinutes;

            await mosqueNotificationRepository.updateMosquePrayerTime(
              mosqueId: mosqueId,
              mosqueName: _mosqueNameController.text.trim(),
              mosqueLatitude: latLng!.latitude,
              mosqueLongitude: latLng!.longitude,
              prayerName: prayerName,
              timeType: 'iqamah',
              adjustmentMinutes: iqamahAdjustmentMinutes,
              onMosqueAdjustmentUpdated: (mosqueId) {
                final mosqueRepository = getIt<MosqueRepository>();
                mosqueRepository.clearCacheForMosque(mosqueId);
              },
            );
          } catch (e) {
            logger.w('⚠️ Skipping iqamah time for $prayerName: $e');
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Mosque added! ${prayerAdjustments.length} prayer adjustments saved.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.pop();
      }
    } catch (e) {
      logger.e('❌ Error adding mosque: $e');
      _showErrorSnackBar('Failed to add mosque: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Rest of the widget classes remain similar, but I'll add timezone info display

class _MosqueInfoSection extends StatelessWidget {
  final TextEditingController mosqueNameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController websiteController;
  final TextEditingController additionalInfoController;
  final LatLng? latLng;
  final String? mosqueTimezone;
  final Function(LatLng, String) onLocationSelected;

  const _MosqueInfoSection({
    required this.mosqueNameController,
    required this.addressController,
    required this.phoneController,
    required this.websiteController,
    required this.additionalInfoController,
    required this.latLng,
    this.mosqueTimezone,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mosque Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please provide details about the mosque. Prayer times will be calculated for the mosque\'s timezone.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 24),
        _FormField(
          icon: Icons.mosque,
          label: 'Mosque Name',
          isRequired: true,
          child: InputEditText(
            controller: mosqueNameController,
            hint: 'Enter the name of the mosque',
            inputType: TextInputType.text,
          ),
        ),
        const SizedBox(height: 16),
        _FormField(
          icon: Icons.location_on,
          label: 'Address',
          isRequired: true,
          child: _AddressField(
            controller: addressController,
            latLng: latLng,
            onLocationSelected: onLocationSelected,
          ),
        ),
        const SizedBox(height: 16),
        _ContactInfoRow(
          phoneController: phoneController,
          websiteController: websiteController,
        ),
        const SizedBox(height: 16),
        _FormField(
          label: 'Additional Information (optional)',
          child: InputEditText(
            controller: additionalInfoController,
            hint: 'Add any useful information',
            maxLines: 4,
            inputType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}

class _PrayerTimesSection extends StatelessWidget {
  final Map<String, Map<String, Map<String, TextEditingController>>>
  prayerTimeControllers;
  final String? mosqueTimezone;

  const _PrayerTimesSection({
    required this.prayerTimeControllers,
    this.mosqueTimezone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('Prayer Times', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          mosqueTimezone != null
              ? 'Times shown in mosque\'s local timezone ($mosqueTimezone). Adjust if needed.'
              : 'Please adjust times to match actual mosque timings.',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 16),
        _PrayerTimesTable(prayerTimeControllers: prayerTimeControllers),
      ],
    );
  }
}

// Keep all other widget classes the same as original
// (_FormField, _AddressField, _ContactInfoRow, _PrayerTimesTable, etc.)

class _PrayerTimesTable extends StatelessWidget {
  final Map<String, Map<String, Map<String, TextEditingController>>>
  prayerTimeControllers;

  const _PrayerTimesTable({required this.prayerTimeControllers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Row(
          children: [
            const Expanded(
              flex: 2,
              child: Text(
                'Prayer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Adhan Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Iqamah Time',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Prayer Time Rows
        ...prayerTimeControllers.entries.map((entry) {
          final prayerName = entry.key;
          final timeTypes = entry.value;

          return _PrayerTimeRow(
            prayerName: prayerName,
            adhanHourController: timeTypes['adhan']!['hour']!,
            adhanMinuteController: timeTypes['adhan']!['minute']!,
            iqamahHourController: timeTypes['iqamah']!['hour']!,
            iqamahMinuteController: timeTypes['iqamah']!['minute']!,
          );
        }),
      ],
    );
  }
}

class _PrayerTimeRow extends StatelessWidget {
  final String prayerName;
  final TextEditingController adhanHourController;
  final TextEditingController adhanMinuteController;
  final TextEditingController iqamahHourController;
  final TextEditingController iqamahMinuteController;

  const _PrayerTimeRow({
    required this.prayerName,
    required this.adhanHourController,
    required this.adhanMinuteController,
    required this.iqamahHourController,
    required this.iqamahMinuteController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Prayer name column
          Expanded(flex: 2, child: Text(prayerName)),
          // Adhan time column
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _SplitTimeField(
                hourController: adhanHourController,
                minuteController: adhanMinuteController,
              ),
            ),
          ),
          // Iqamah time column
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _SplitTimeField(
                hourController: iqamahHourController,
                minuteController: iqamahMinuteController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitTimeField extends StatelessWidget {
  final TextEditingController hourController;
  final TextEditingController minuteController;

  const _SplitTimeField({
    required this.hourController,
    required this.minuteController,
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
          // Hour field
          _TimeFormField(controller: hourController, isHour: true).expanded(),
          // Colon separator
          const Text(
            ':',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Minute field
          _TimeFormField(
            controller: minuteController,
            isHour: false,
          ).expanded(),
          // Clock icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.access_time, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }
}

class _TimeFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool isHour;

  const _TimeFormField({required this.controller, required this.isHour});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
        isHour ? HourInputFormatter() : MinuteInputFormatter(),
      ],
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _RequiredFieldsNote extends StatelessWidget {
  const _RequiredFieldsNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '*Required fields',
      style: TextStyle(color: Colors.grey, fontSize: 14),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _ActionButtons({
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Mosque', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class HourInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Clear default "--" when user starts typing
    if (oldValue.text == "--" && text.isNotEmpty && text != "--") {
      text = text.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (text.isEmpty) return newValue.copyWith(text: ""); // Allow empty input

    int? value = int.tryParse(text);

    if (value == null || value < 0 || value > 23) {
      return oldValue; // Reject invalid input
    }

    return newValue.copyWith(text: text);
  }
}

class MinuteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Clear default "--" when user starts typing
    if (oldValue.text == "--" && text.isNotEmpty && text != "--") {
      text = text.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (text.isEmpty) return newValue.copyWith(text: ""); // Allow empty input

    int? value = int.tryParse(text);

    if (value == null || value < 0 || value > 59) {
      return oldValue; // Reject invalid input
    }

    return newValue.copyWith(text: text);
  }
}

class _FormField extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isRequired;
  final Widget child;

  const _FormField({
    this.icon,
    required this.label,
    this.isRequired = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontSize: 16)),
            if (isRequired)
              const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final LatLng? latLng;
  final Function(LatLng, String) onLocationSelected;

  const _AddressField({
    required this.controller,
    required this.latLng,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InputEditText(
      controller: controller,
      inputType: TextInputType.streetAddress,
      readOnly: true,
      hint: 'Street address, city, state, zip',
      onTap: () async {
        final result = await context.pushNamed<GeocodingResult?>(
          Routes.mapsLocationPicker.name,
          queryParameters: {
            "lat": (latLng?.latitude).toString(),
            "lng": (latLng?.longitude).toString(),
          },
        );

        if (result != null) {
          final selectedLatLng = LatLng(
            result.geometry.location.lat,
            result.geometry.location.lng,
          );
          final locName =
              result.formattedAddress ??
              '${result.geometry.location.lat}, ${result.geometry.location.lng}';
          onLocationSelected(selectedLatLng, locName);
          logger.d('Selected Location: $locName');
        }
      },
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController websiteController;

  const _ContactInfoRow({
    required this.phoneController,
    required this.websiteController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.grey),
            gapW8,
            const Text(
              'Phone (optional)',
              style: TextStyle(fontSize: 16),
            ).expanded(),
            gapW16,
            Text(
              'Website (optional)',
              style: TextStyle(fontSize: 16),
            ).expanded(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputEditText(
              controller: phoneController,
              hint: 'Phone number',
              inputType: TextInputType.number,
            ).expanded(),
            gapW16,
            InputEditText(
              controller: websiteController,
              hint: 'Website URL',
              inputType: TextInputType.url,
            ).expanded(),
          ],
        ),
      ],
    );
  }
}
