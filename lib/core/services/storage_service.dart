import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveAuthToken(String token) async {
    await _prefs?.setString(AppConstants.keyToken, token);
    await _prefs?.setBool(AppConstants.keyIsLoggedIn, true);
  }

  static String? getAuthToken() {
    return _prefs?.getString(AppConstants.keyToken);
  }

  static bool isLoggedIn() {
    return _prefs?.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  static Future<void> saveUser(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _prefs?.setString(AppConstants.keyUser, jsonStr);
    // Also save permanently by phone number so user profile persists across logouts
    if (user.phone.isNotEmpty) {
      await _prefs?.setString('user_profile_${user.phone}', jsonStr);
    }
  }

  static UserModel? getUser() {
    final jsonStr = _prefs?.getString(AppConstants.keyUser);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr);
        return UserModel.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  static UserModel? getSavedUserByPhone(String phone) {
    final jsonStr = _prefs?.getString('user_profile_$phone');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr);
        return UserModel.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> saveActiveLoanId(String loanId) async {
    await _prefs?.setString(AppConstants.keyActiveLoanId, loanId);
  }

  static String? getActiveLoanId() {
    return _prefs?.getString(AppConstants.keyActiveLoanId);
  }

  static Future<void> setCustomBaseUrl(String url) async {
    await _prefs?.setString(AppConstants.keyBaseUrl, url);
  }

  static String getBaseUrl() {
    return _prefs?.getString(AppConstants.keyBaseUrl) ?? AppConstants.defaultBaseUrl;
  }

  // ── Password (stored locally for offline verification) ────────────────────
  static Future<void> savePassword(String phone, String hashedPass) async {
    await _prefs?.setString('pwd_$phone', hashedPass);
  }

  static String? getSavedPassword(String phone) {
    return _prefs?.getString('pwd_$phone');
  }

  static Future<void> clearSession() async {
    await _prefs?.remove(AppConstants.keyToken);
    await _prefs?.remove(AppConstants.keyUser);
    await _prefs?.setBool(AppConstants.keyIsLoggedIn, false);
    // keep activeLoanId, customBaseUrl, and saved passwords intact
  }
}
