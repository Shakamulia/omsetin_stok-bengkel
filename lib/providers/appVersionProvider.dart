import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionProvider with ChangeNotifier {
  String _appVersion = '';

  String get appVersion => _appVersion;

  set appVersion(String version) {
    _appVersion = version;
    notifyListeners();
  }

  Future<void> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      debugPrint("App Version: $appVersion");
    } catch (e) {
      debugPrint("Error getting app version: $e");
    }
  }
}
