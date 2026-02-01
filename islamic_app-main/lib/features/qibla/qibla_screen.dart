import 'dart:math';
import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/core/widgets/scaffold/app_bar_scaffold.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import 'package:deenhub/features/qibla/qibla_faq_screen.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QiblaFinderScreen();
  }
}

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  _QiblaFinderScreenState createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isCalibrating = true;
  bool _isLocationEnabled = false;
  double _direction = 0;
  double _qiblaDirection = 0;
  double _distanceToKaaba = 0;
  List<CameraDescription> _cameras = [];
  bool _isQiblaAligned = false;
  bool _showSuccessOverlay = false;
  bool _isAlignmentInProgress = false;
  double _alignmentProgress = 0.0;
  bool _isWithinQiblaRegion = false; // New flag for visibility control

  // 3D perspective settings
  double _perspectiveScale = 1.0;

  // Animation controller for the 3D Kaaba
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pathAnimation;

  // AR Path points for directional path
  List<Offset> _arPathPoints = [];
  List<double> _pathDepths = []; // Depth values for each point
  final int _numberOfPathPoints = 12; // Optimized for single stage

  // Direction indicators
  bool _showLeftIndicator = false;
  bool _showRightIndicator = false;

  // Timer for alignment progress
  DateTime? _alignmentStartTime;

  // Constants - Updated with Google's exact coordinates
  final double kaabaLatitude = 21.4224779;
  final double kaabaLongitude = 39.8251832;
  final double alignmentThreshold = 10.0; // Tolerance for exact alignment
  final double regionThreshold =
      45.0; // Tolerance for showing the path (wider region)
  final int alignmentDurationMs =
      3000; // Time in milliseconds user needs to stay aligned

  // 3D AR Path design settings
  final List<Color> _pathGradientColors = [
    Colors.white,
    Colors.green,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _floatAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeResources();
  }

  Future<void> _initializeResources() async {
    await _checkPermissions();
    if (_isPermissionGranted) {
      await _getCameras();
      _initializeCamera();
      _initializeCompass();
      _determinePosition();
    }
  }

  Future<void> _getCameras() async {
    _cameras = await availableCameras();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.location.request();

    final wasPermissionGranted = _isPermissionGranted;
    final isNowPermissionGranted =
        cameraStatus.isGranted && locationStatus.isGranted;

    setState(() {
      _isPermissionGranted = isNowPermissionGranted;
    });

    // If permissions were just granted for the first time, reinitialize everything
    if (!wasPermissionGranted && isNowPermissionGranted) {
      logger.i(
        'Permissions granted for first time, reinitializing camera and location',
      );
      await _reinitializeAfterPermission();
    }
  }

  Future<void> _reinitializeAfterPermission() async {
    try {
      await _getCameras();
      _initializeCamera();
      _initializeCompass();
      await _determinePosition();
      logger.i('Reinitialization completed successfully');
    } catch (e) {
      logger.e('Error during reinitialization: $e');
    }
  }

  void _initializeCamera() async {
    if (_cameras.isEmpty) return;

    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.medium,
      enableAudio: false, // Disable audio to avoid audio permission request
    );

    try {
      await _cameraController.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      logger.i('Error initializing camera: $e');
    }
  }

  void _initializeCompass() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          // The compass heading is the direction the device is pointing
          _direction = event.heading ?? 0;

          // Set calibrating to false after we get our first reading
          _isCalibrating = false;

          // Generate AR path points
          _generateSimpleARLine();

          // Update turn indicators
          _updateDirectionIndicators();

          // Check if the current direction is aligned with Qibla
          _checkQiblaAlignment();
        });
      }
    });
  }

  void _generateSimpleARLine() {
    _arPathPoints = [];
    _pathDepths = [];

    // Calculate the angle difference between current direction and Qibla
    double angleDiff = _qiblaDirection - _direction;

    // Normalize to -180 to 180 degrees
    if (angleDiff > 180) angleDiff -= 360;
    if (angleDiff < -180) angleDiff += 360;

    // Check if we're within the region to show the path
    double absAngleDiff = angleDiff.abs();
    _isWithinQiblaRegion = absAngleDiff <= regionThreshold;

    if (!_isWithinQiblaRegion) {
      return; // Don't generate path if not within region
    }

    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double centerX = screenWidth / 2;

    // Create a simple straight line from bottom center to Kaaba position
    double startY =
        screenHeight - 150; // Start from bottom with padding for info box
    double endY = screenHeight * 0.3; // End at 30% of screen

    // Calculate horizontal offset based on angle difference
    double horizontalOffset =
        tan(vector_math.radians(angleDiff)) * (startY - endY);
    // Limit horizontal offset to screen bounds
    horizontalOffset = horizontalOffset.clamp(
      -screenWidth * 0.4,
      screenWidth * 0.4,
    );

    double endX = centerX + horizontalOffset;

    // Create simple 2-point line
    _arPathPoints = [
      Offset(centerX, startY), // Start from bottom center
      Offset(endX, endY), // End at Kaaba position
    ];

    _pathDepths = [0.8, 0.2]; // Simple depth values
  }

  void _updateDirectionIndicators() {
    // Normalize direction to [0, 360)
    double normalizedDirection = (_direction % 360 + 360) % 360;
    double normalizedQibla = (_qiblaDirection % 360 + 360) % 360;

    // Calculate the difference between current direction and Qibla direction
    double diff = (normalizedDirection - normalizedQibla).abs();
    if (diff > 180) diff = 360 - diff;

    // Define a tolerance range for near Qibla (45 degrees)
    bool isNearQibla = diff <= 45;

    // Calculate the actual angle difference taking the shortest path
    double angleDiff = normalizedDirection - normalizedQibla;
    if (angleDiff > 180) angleDiff -= 360;
    if (angleDiff < -180) angleDiff += 360;

    setState(() {
      // Update Qibla aligned state
      _isQiblaAligned = diff <= alignmentThreshold;

      // Calculate perspective scale based on alignment
      _perspectiveScale = 1.0 + (isNearQibla ? (1.0 - diff / 45.0) * 0.6 : 0);

      // Show turn indicators based on direction to turn
      _showLeftIndicator = !isNearQibla && (angleDiff > 0);
      _showRightIndicator = !isNearQibla && (angleDiff < 0);
    });
  }

  void _checkQiblaAlignment() {
    // Normalize direction to [0, 360)
    double normalizedDirection = (_direction % 360 + 360) % 360;
    double normalizedQibla = (_qiblaDirection % 360 + 360) % 360;

    // Calculate the difference between current direction and Qibla direction
    double diff = (normalizedDirection - normalizedQibla).abs();
    if (diff > 180) diff = 360 - diff;

    bool isNearQibla = diff <= alignmentThreshold;

    // Update alignment progress if close to alignment
    if (isNearQibla) {
      // If we just started alignment
      if (!_isAlignmentInProgress) {
        _alignmentStartTime = DateTime.now();
        setState(() {
          _isAlignmentInProgress = true;
          _alignmentProgress = 0;
        });
      } else {
        // Calculate progress based on time spent aligned
        final now = DateTime.now();
        final timeAligned = now.difference(_alignmentStartTime!).inMilliseconds;
        final percentComplete = timeAligned / alignmentDurationMs;

        setState(() {
          _alignmentProgress = percentComplete.clamp(0.0, 1.0);
        });

        // If we've been aligned long enough, show success
        if (percentComplete >= 1.0 && !_showSuccessOverlay) {
          _showAlignmentSuccess();
        }
      }
    } else {
      // Reset if we lost alignment
      if (_isAlignmentInProgress) {
        setState(() {
          _isAlignmentInProgress = false;
          _alignmentProgress = 0;
        });
      }
    }
  }

  void _showAlignmentSuccess() {
    setState(() {
      _showSuccessOverlay = true;
    });

    // Start animation
    _animationController.forward(from: 0.0);

    // Hide the success overlay after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSuccessOverlay = false;
          _isQiblaAligned = false;
        });
      }
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocationEnabled = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLocationEnabled = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationEnabled = false;
      });
      return;
    }

    setState(() {
      _isLocationEnabled = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition();
      _calculateQiblaDirection(position.latitude, position.longitude);
    } catch (e) {
      logger.i('Error getting position: $e');
    }
  }

  void _calculateQiblaDirection(double latitude, double longitude) {
    // Convert to radians
    double latRad = vector_math.radians(latitude);
    double longRad = vector_math.radians(longitude);
    double kaabaLatRad = vector_math.radians(kaabaLatitude);
    double kaabaLongRad = vector_math.radians(kaabaLongitude);

    // Calculate qibla direction using the great circle formula
    double y = sin(kaabaLongRad - longRad);
    double x =
        cos(latRad) * tan(kaabaLatRad) -
        sin(latRad) * cos(kaabaLongRad - longRad);
    double qiblaRad = atan2(y, x);
    double qiblaDeg = vector_math.degrees(qiblaRad);

    // Normalize to 0-360
    _qiblaDirection = (qiblaDeg + 360) % 360;

    // Calculate distance to Kaaba using the Haversine formula
    _distanceToKaaba =
        Geolocator.distanceBetween(
          latitude,
          longitude,
          kaabaLatitude,
          kaabaLongitude,
        ) /
        1000; // Convert to kilometers

    logger.i(
      "Calculated Qibla Direction: $_qiblaDirection for lat: $latitude, long: $longitude",
    );
    setState(() {});
  }

  // Simple AR line to Kaaba
  Widget _buildSimpleARLine() {
    if (!_isWithinQiblaRegion || _arPathPoints.isEmpty) {
      return const SizedBox(); // Only show when within Qibla region
    }

    return Stack(
      children: [
        // Simple AR Line
        CustomPaint(
          size: Size.infinite,
          painter: SimpleARLinePainter(
            points: _arPathPoints,
            isAligned: _isQiblaAligned,
            primaryColor: context.primaryColor,
            glowAnimation: _glowAnimation.value,
          ),
        ),

        // Kaaba at the end of the line
        if (_arPathPoints.isNotEmpty) _buildKaabaAtEnd(),
      ],
    );
  }

  // Simple Kaaba positioned at the end of the AR line
  Widget _buildKaabaAtEnd() {
    if (_arPathPoints.isEmpty) return const SizedBox();

    // Position Kaaba at the end of the line (last point)
    final kaabaPosition = _arPathPoints.last;
    double kaabaSize = 70; // Bigger size

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: kaabaPosition.dy - kaabaSize / 2 + _floatAnimation.value * 0.5,
          left: kaabaPosition.dx - kaabaSize / 2,
          child: Container(
            width: kaabaSize,
            height: kaabaSize,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  context.primaryColor.withValues(
                    alpha: _glowAnimation.value * 0.9,
                  ),
                  context.primaryColor.withValues(
                    alpha: _glowAnimation.value * 0.6,
                  ),
                  context.primaryColor.withValues(
                    alpha: _glowAnimation.value * 0.2,
                  ),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(
                    alpha: _glowAnimation.value * 0.7,
                  ),
                  blurRadius: 15 * _glowAnimation.value,
                  spreadRadius: 4 * _glowAnimation.value,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: _glowAnimation.value * 0.8,
                ),
                width: 2,
              ),
            ),
            child: Center(
              child: ImageView(
                width: kaabaSize * 0.7,
                height: kaabaSize * 0.7,
                imagePath: Assets.imagesIcKaabaFilled,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return AppBarScaffold(
        pageTitle: 'Qibla Finder',
        appBarActions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QiblaFaqScreen()),
              );
            },
          ),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Camera and Location Permission Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'We need camera and location permissions to find the Qibla direction.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Grant Permission',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLocationEnabled) {
      return AppBarScaffold(
        pageTitle: 'Qibla Finder',
        appBarActions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QiblaFaqScreen()),
              );
            },
          ),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Location Service Disabled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please enable location services on your device to use the Qibla finder.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _determinePosition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return AppBarScaffold(
        pageTitle: 'Qibla Finder',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppBarScaffold(
      pageTitle: 'Qibla Finder',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QiblaFaqScreen()),
            );
          },
        ),
      ],
      child: Stack(
        children: [
          // Camera preview - Full screen
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_cameraController),
          ),

          // Subtle AR Grid overlay
          CustomPaint(size: Size.infinite, painter: Subtle3DARGridPainter()),

          // Calibrating indicator
          if (_isCalibrating)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: context.primaryColor),
                    const SizedBox(height: 20),
                    const Text(
                      "Calibrating compass...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please move your phone in a figure 8 pattern",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Center crosshair
          Positioned.fill(
            child: Center(
              child: Container(
                width: 2,
                height: 30,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: 30,
                height: 2,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Simple AR Line to Kaaba (only visible when within region)
          if (!_isCalibrating) _buildSimpleARLine(),

          // Direction indicators (only when not in Qibla region and not calibrating)
          if (!_isCalibrating && !_isWithinQiblaRegion) ...[
            // Left indicator arrow
            if (_showLeftIndicator)
              Positioned(
                left: 25,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.25 * _glowAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: ThemeColors.green.withValues(
                            alpha: _glowAnimation.value * 0.85,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.green.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Right indicator arrow
            if (_showRightIndicator)
              Positioned(
                right: 25,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.25 * _glowAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: ThemeColors.green.withValues(
                            alpha: _glowAnimation.value * 0.85,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.green.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],

          // Alignment progress indicator
          if (!_isCalibrating && _isAlignmentInProgress)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _alignmentProgress,
                        strokeWidth: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        color: ThemeColors.green,
                      ),
                    ),
                    Text(
                      "${(_alignmentProgress * 100).toInt()}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Always visible direction guide at the bottom
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: Card(
              elevation: 15,
              color: Colors.black.withValues(alpha: 0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCalibrating
                              ? Icons.compass_calibration
                              : _isAlignmentInProgress
                              ? Icons.timer
                              : _isQiblaAligned
                              ? Icons.check_circle
                              : _isWithinQiblaRegion
                              ? Icons.navigation
                              : Icons.explore,
                          color: _isCalibrating
                              ? Colors.orange
                              : _isWithinQiblaRegion
                              ? ThemeColors.green
                              : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _isCalibrating
                                ? "Calibrating..."
                                : _isAlignmentInProgress
                                ? "Hold steady..."
                                : (_isQiblaAligned
                                      ? "Perfect alignment!"
                                      : _isWithinQiblaRegion
                                      ? "Follow the line to Kaaba"
                                      : "Turn to find Qibla direction"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_distanceToKaaba.toStringAsFixed(0)} km to Kaaba",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "Qibla: ${_qiblaDirection.toStringAsFixed(1)}°",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Current: ${_direction.toStringAsFixed(1)}°",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Success overlay
          if (_showSuccessOverlay && _isQiblaAligned)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large glowing check icon
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                context.primaryColor.withValues(
                                  alpha: _glowAnimation.value * 0.8,
                                ),
                                context.primaryColor.withValues(
                                  alpha: _glowAnimation.value * 0.4,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 120,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // Main success message
                    const Text(
                      "You are on the correct path!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    // Secondary message
                    const Text(
                      "Facing the Kaaba perfectly",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    // Distance info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "${_distanceToKaaba.toStringAsFixed(0)} km to Kaaba",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Subtle 3D AR Grid Painter with minimal visual impact
class Subtle3DARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Minimal grid with subtle perspective
    double vanishingPointY = size.height * 0.45;
    double vanishingPointX = size.width * 0.5;

    // Draw subtle horizontal lines
    final spacing = size.height / 15;
    for (var i = 0; i < 12; i++) {
      double y = vanishingPointY + i * spacing;
      double perspective = 0.5 + 0.5 * (i / 12);

      double startX = vanishingPointX - (size.width * perspective / 2);
      double endX = vanishingPointX + (size.width * perspective / 2);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }

    // Draw subtle vertical lines
    final vCount = 8;
    for (var i = 0; i <= vCount; i++) {
      double normalizedX = i / vCount;

      Offset start = Offset(vanishingPointX, vanishingPointY);
      Offset end = Offset(
        size.width * 0.1 + normalizedX * size.width * 0.8,
        size.height,
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(Subtle3DARGridPainter oldDelegate) => false;
}

// Simple AR Line Painter
class SimpleARLinePainter extends CustomPainter {
  final List<Offset> points;
  final bool isAligned;
  final Color primaryColor;
  final double glowAnimation;

  SimpleARLinePainter({
    required this.points,
    required this.isAligned,
    required this.primaryColor,
    required this.glowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || points.length < 2) return;

    final baseColor = isAligned ? primaryColor : Colors.white;
    final startPoint = points[0];
    final endPoint = points[1];

    // Create 3D perspective line by drawing multiple segments with varying widths
    const int segments = 20; // Number of segments to create smooth tapering

    for (int i = 0; i < segments; i++) {
      double t = i / (segments - 1); // Progress from 0 to 1
      double nextT = (i + 1) / (segments - 1);

      // Calculate segment start and end points
      Offset segmentStart = Offset(
        startPoint.dx + (endPoint.dx - startPoint.dx) * t,
        startPoint.dy + (endPoint.dy - startPoint.dy) * t,
      );

      Offset segmentEnd = Offset(
        startPoint.dx + (endPoint.dx - startPoint.dx) * nextT,
        startPoint.dy + (endPoint.dy - startPoint.dy) * nextT,
      );

      // 3D perspective width - starts wide, ends thinner (but not too thin)
      double startWidth = 40.0 * glowAnimation; // Wide start
      double endWidth = 16.0 * glowAnimation; // Thinner end (not too thin)
      double segmentWidth = startWidth + (endWidth - startWidth) * t;

      // Main line segment
      final Paint linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = segmentWidth
        ..strokeCap = StrokeCap.round
        ..color = baseColor;
      // ..color = baseColor.withValues(alpha: (0.8 - t * 0.2) * glowAnimation);

      canvas.drawLine(segmentStart, segmentEnd, linePaint);

      // Glow effect with perspective
      double glowWidth = segmentWidth * 1.1;
      final Paint glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = glowWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = baseColor.withValues(alpha: (0.3 - t * 0.1) * glowAnimation);

      canvas.drawLine(segmentStart, segmentEnd, glowPaint);
    }

    // Draw outer glow for the entire line
    final Paint outerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0 * glowAnimation
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..color = baseColor.withValues(alpha: 0.1 * glowAnimation);

    canvas.drawLine(startPoint, endPoint, outerGlowPaint);
  }

  @override
  bool shouldRepaint(SimpleARLinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.isAligned != isAligned ||
      oldDelegate.glowAnimation != glowAnimation;
}
