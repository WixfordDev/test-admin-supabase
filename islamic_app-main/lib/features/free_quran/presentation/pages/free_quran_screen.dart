import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/config/themes/styles.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/edit_text/input_edit_text.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:deenhub/map_location_picker/map_location_picker.dart';
import 'package:deenhub/features/free_quran/data/services/free_quran_service.dart';
import 'package:deenhub/main.dart';

class FreeQuranScreen extends StatefulWidget {
  const FreeQuranScreen({super.key});

  @override
  State<FreeQuranScreen> createState() => _FreeQuranScreenState();
}

class _FreeQuranScreenState extends State<FreeQuranScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  LatLng? _selectedLocation;

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  // Dropdown values
  String? _selectedState;
  String? _selectedLanguage;
  String? _selectedReason;

  // US States list
  final List<String> _usStates = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming'
  ];

  // Language options
  final List<String> _languages = [
    'Arabic',
    'English',
    'Arabic with English Translation',
    'Spanish',
    'French',
    'Urdu',
    'Turkish',
    'Malay',
    'Other'
  ];

  // Reasons for requesting
  final List<String> _reasons = [
    'New to Islam',
    'Personal Study',
    'Gift for Family/Friend',
    'Educational Purpose',
    'Lost/Damaged Previous Copy',
    'Community Distribution',
    'Other'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Your Free Quran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: p16,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: p16,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: context.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Request Your Free Quran',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      gapH8,
                      Container(
                        padding: p8,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange, size: 20),
                            gapW8,
                            const Text(
                              'Only available for United States',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      gapH8,
                      const Text(
                        'Fill out the form below and we\'ll send a complimentary copy of the Quran to your address.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                gapH24,

                // Personal Information Section
                _buildSectionHeader('Personal Information',
                    'Please provide your details for shipping your free Quran.'),

                gapH16,

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Full Name *',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          gapH8,
                          InputEditText(
                            controller: _fullNameController,
                            hint: 'John Doe',
                            validationLabel: 'Please enter your full name',
                          ),
                        ],
                      ),
                    ),
                    gapW16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Address *',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          gapH8,
                          InputEditText(
                            controller: _emailController,
                            hint: 'john@example.com',
                            inputType: TextInputType.emailAddress,
                            validationLabel: 'Please enter a valid email',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                gapH24,

                // Shipping Address Section
                _buildSectionHeader('Shipping Address', null),

                gapH16,

                // Address field with location picker
                const Text('Shipping Address *',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                gapH8,
                Row(
                  children: [
                    Expanded(
                      child: InputEditText(
                        controller: _addressController,
                        hint: '123 Main Street',
                        readOnly: true,
                        validationLabel: 'Please select your address',
                        onTap: () async {
                          final result = await _selectLocation();
                          if (result != null) {
                            _processSelectedLocation(result);
                          }
                        },
                      ),
                    ),
                    gapW8,
                    IconButton(
                      onPressed: () async {
                        final result = await _selectLocation();
                        if (result != null) {
                          _processSelectedLocation(result);
                        }
                      },
                      icon: const Icon(Icons.location_on),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            context.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),

                gapH16,

                // City and State row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('City *',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          gapH8,
                          InputEditText(
                            controller: _cityController,
                            hint: 'New York',
                            validationLabel: 'Please enter your city',
                          ),
                        ],
                      ),
                    ),
                    gapW16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'State/Province *',
                            style: TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          gapH8,
                          DropdownButtonFormField<String>(
                            value: _selectedState,
                            hint: const Text('Select state'),
                            items: _usStates
                                .map((state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedState = value),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select your state';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                gapH16,

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Zip/Postal Code *',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          gapH8,
                          InputEditText(
                            controller: _zipController,
                            hint: '10001',
                            inputType: TextInputType.text,
                            validationLabel: 'Please enter your zip code',
                          ),
                        ],
                      ),
                    ),
                    gapW16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Country',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          gapH8,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade100,
                            ),
                            child: const Text(
                              'United States',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                gapH24,

                // Preferred Language Section
                const Text('Preferred Language of Quran',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                gapH8,
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  hint: const Text('Select language'),
                  items: _languages
                      .map((language) => DropdownMenuItem(
                            value: language,
                            child: Text(language),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                ),

                gapH16,

                // Reason Section
                const Text('Reason for Requesting a Quran',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                gapH8,
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  hint: const Text('Select reason'),
                  items: _reasons
                      .map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedReason = value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                ),

                gapH24,

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Get My Free Quran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                gapH24,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null) ...[
          gapH4,
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Future<GeocodingResult?> _selectLocation() async {
    try {
      // Get current location from shared prefs for default location
      final SharedPrefsHelper sharedPrefsHelper = getIt<SharedPrefsHelper>();
      final currentPrayerData = sharedPrefsHelper.prayerLocationData!;

      LatLng defaultLocation = const LatLng(39.8283, -98.5795); // Center of US
      if (currentPrayerData != null) {
        defaultLocation = LatLng(currentPrayerData.lat, currentPrayerData.lng);
      }

      final result = await context.pushNamed<GeocodingResult?>(
        Routes.mapsLocationPicker.name,
        queryParameters: {
          "lat": defaultLocation.latitude.toString(),
          "lng": defaultLocation.longitude.toString(),
        },
      );

      return result;
    } catch (e) {
      logger.e('Error selecting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening location picker'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  void _processSelectedLocation(GeocodingResult result) {
    try {
      _selectedLocation =
          LatLng(result.geometry.location.lat, result.geometry.location.lng);

      // Extract address components
      String streetAddress = '';
      String city = '';
      String state = '';
      String zipCode = '';

      // Parse the formatted address or use address components
      if (result.addressComponents != null) {
        for (var component in result.addressComponents!) {
          if (component.types.contains('street_number')) {
            streetAddress = component.longName;
          } else if (component.types.contains('route')) {
            streetAddress += ' ${component.longName}';
          } else if (component.types.contains('locality') ||
              component.types.contains('administrative_area_level_2')) {
            city = component.longName;
          } else if (component.types.contains('administrative_area_level_1')) {
            state = component.longName;
          } else if (component.types.contains('postal_code')) {
            zipCode = component.longName;
          }
        }
      }

      // Update form fields
      if (streetAddress.isNotEmpty) {
        _addressController.text = streetAddress.trim();
      } else {
        _addressController.text = result.formattedAddress ?? '';
      }

      if (city.isNotEmpty) {
        _cityController.text = city;
      }

      if (zipCode.isNotEmpty) {
        _zipController.text = zipCode;
      }

      // Set state if it's a valid US state
      if (state.isNotEmpty && _usStates.contains(state)) {
        setState(() {
          _selectedState = state;
        });
      }

      logger.d('Location selected: ${result.formattedAddress}');
    } catch (e) {
      logger.e('Error processing selected location: $e');
      // Fallback to just using the formatted address
      _addressController.text = result.formattedAddress ??
          '${result.geometry.location.lat}, ${result.geometry.location.lng}';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final freeQuranService = getIt<FreeQuranService>();

      await freeQuranService.submitFreeQuranRequest(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _selectedState!,
        zipCode: _zipController.text.trim(),
        country: 'United States',
        preferredLanguage: _selectedLanguage,
        reason: _selectedReason,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your request has been submitted successfully! We will process your request and send you a free Quran soon.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );

        // Navigate back to previous screen
        context.pop();
      }
    } catch (e) {
      logger.e('Error submitting free Quran request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
