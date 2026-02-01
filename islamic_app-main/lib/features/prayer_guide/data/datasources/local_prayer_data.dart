import 'package:deenhub/features/prayer_guide/domain/model/prayer_step.dart';

final List<PrayerStep> wuduSteps = [
  PrayerStep(
    title: 'Intention (Niyyah)',
    description: 'Make the intention in your heart to perform wudu',
    imagePath: 'assets/images/wudu/niyyah.jpg',
  ),
  PrayerStep(
    title: 'Washing Hands',
    description: 'Wash your hands three times, starting with the right hand',
    imagePath: 'assets/images/wudu/hands.jpg',
    videoPath: 'assets/videos/wudu/hands.mp4',
  ),
  // ... rest of the steps ...
]; 