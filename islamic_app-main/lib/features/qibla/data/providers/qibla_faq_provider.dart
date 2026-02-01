import 'package:deenhub/features/qibla/domain/models/qibla_faq.dart';

class QiblaFaqProvider {
  List<QiblaFaq> getFaqs() {
    return [
      QiblaFaq(
        question: "What is the DeenHub Qibla Finder?",
        answer: "The DeenHub Qibla Finder helps you determine the direction of the Kaaba in Mecca from anywhere in the world, so you can perform your prayers facing the correct direction.",
      ),
      QiblaFaq(
        question: "How does it work?",
        answer: "Our Qibla Finder uses your device's GPS and digital compass to accurately calculate and display the direction of the Qibla based on your location.",
      ),
      QiblaFaq(
        question: "Do I need an internet connection to use it?",
        answer: "An internet connection and location services are recommended for the most accurate results. However, once your location is known, the direction can still be shown offline.",
      ),
      QiblaFaq(
        question: "How accurate does my direction need to be when facing the Qibla?",
        answer: "You do not need to face the Kaaba with 100% precision. It is sufficient to face the general direction of the Kaaba, especially when you're far from Mecca. Allah is Most Merciful, and intention matters more than exact degrees.",
      ),
      QiblaFaq(
        question: "How can I improve accuracy?",
        answer: "Make sure your phone's location and compass are enabled. Calibrate your compass by moving your phone in a figure-eight motion and avoid metal or electronic interference.",
      ),
      QiblaFaq(
        question: "Can I use the Qibla Finder indoors?",
        answer: "You can, but accuracy may be affected by walls or electronic interference. For best results, use the app outdoors or near a window.",
      ),
      QiblaFaq(
        question: "Is the direction based on the Great Circle method?",
        answer: "Yes, DeenHub's Qibla Finder uses the scientifically accurate Great Circle method, which is widely accepted by scholars and used in modern navigation.",
      ),
      QiblaFaq(
        question: "Is this feature free?",
        answer: "Yes, the Qibla Finder is completely free to use within the DeenHub app.",
      ),
      QiblaFaq(
        question: "Can I use it while traveling?",
        answer: "Absolutely. The app will automatically update your Qibla direction as your location changes.",
      ),
      QiblaFaq(
        question: "Who can I contact if I notice an issue?",
        answer: "Please reach out through the \"Support\" section in the app or email us directly at support@DeenHub.app for any assistance.",
      ),
    ];
  }
}