abstract class Utils {
  static List<String> milesCountries = ["US", "GB", "MM", "LR"]; // USA, UK, Myanmar, Liberia

  static bool usesMiles(String countryCode) {
    return milesCountries.contains(countryCode.toUpperCase());
  }
}
