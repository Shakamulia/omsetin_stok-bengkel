
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  static Future setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _preferences?.getInt(key);
  }
}