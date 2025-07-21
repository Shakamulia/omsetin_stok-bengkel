import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/services/database_service.dart';

class SettingProvider with ChangeNotifier {
  String? settingName;
  String? settingAddress;
  String? settingFooter;
  String? settingImage;

  String? get getSettingName => settingName;
  String? get getSettingAddress => settingAddress;
  String? get getSettingFooter => settingFooter;
  String? get getSettingImage => settingImage;

  Future<Map<String, String?>> getSettingProfile() async {
    try {
      final settings = await DatabaseService.instance.getSettingProfile();
      settingName = settings['settingName'];
      settingAddress = settings['settingAddress'];
      settingFooter = settings['settingFooter'];
      settingImage = settings['settingImage'];
      notifyListeners();
      return {
        'settingName': settingName,
        'settingAddress': settingAddress,
        'settingFooter': settingFooter,
        'settingImage': settingImage,
      };
    } catch (e) {
      print('Failed to load setting profile: $e');
      return {};
    }
  }

  Future<void> updateSettingProfile(
      String name, String address, String footer, String image) async {
    try {
      await DatabaseService.instance
          .updateSettingProfile(name, address, footer, image);
      settingName = name;
      settingAddress = address;
      settingFooter = footer;
      settingImage = image;
      notifyListeners(); // Notify listeners after data is updated
    } catch (e) {
      print('Failed to update setting profile: $e');
    }
  }

  void refreshData() {
    getSettingProfile();
    notifyListeners();
  }
}
