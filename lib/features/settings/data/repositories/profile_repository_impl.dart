import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  static const _kProfileKey = 'user_profile';

  Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kProfileKey);
    if (jsonStr == null) return null;
    return Map<String, dynamic>.from(json.decode(jsonStr) as Map);
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileKey, json.encode(profile));
  }
}
