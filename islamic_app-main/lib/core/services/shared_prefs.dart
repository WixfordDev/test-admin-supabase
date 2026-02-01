import 'package:deenhub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;
  static final SharedPrefs _instance = SharedPrefs._internal();

  factory SharedPrefs() => _instance;

  SharedPrefs._internal();


  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  dynamic getData(String key) {
    // Retrieve data from shared preferences
    var value = _sharedPrefs.get(key);

    // Easily log the data that we retrieve from shared preferences
    // logger.d('Retrieved $key: $value');

    // Return the data that we retrieve from shared preferences
    return value;
  }

  void saveData(String key, dynamic value) {
    // Easily log the data that we save to shared preferences
    logger.d('Saving $key: $value');

    // Save data to shared preferences
    if (value is String) {
      _sharedPrefs.setString(key, value);
    } else if (value is int) {
      _sharedPrefs.setInt(key, value);
    } else if (value is double) {
      _sharedPrefs.setDouble(key, value);
    } else if (value is bool) {
      _sharedPrefs.setBool(key, value);
    } else if (value is List<String>) {
      _sharedPrefs.setStringList(key, value);
    }
  }

  void removeData(String key) {
    // Log the removal
    logger.d('Removing data for key: $key');
    
    // Remove data from shared preferences
    _sharedPrefs.remove(key);
  }

  Future<void> clear() async {
    await _sharedPrefs.clear();
  }
}
