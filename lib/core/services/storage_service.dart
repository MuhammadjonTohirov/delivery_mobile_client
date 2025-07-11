import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_customer/core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure storage methods (for sensitive data like tokens)
  static Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteSecureString(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Regular storage methods
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // JSON storage methods
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  static Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Auth-specific methods
  static Future<void> setAuthToken(String token) async {
    await setSecureString(AppConstants.tokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    return await getSecureString(AppConstants.tokenKey);
  }

  static Future<void> removeAuthToken() async {
    await deleteSecureString(AppConstants.tokenKey);
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await setJson(AppConstants.userKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    return getJson(AppConstants.userKey);
  }

  static Future<void> removeUserData() async {
    await remove(AppConstants.userKey);
  }

  // Cart-specific methods
  static Future<void> setCartData(List<Map<String, dynamic>> cartItems) async {
    final jsonString = jsonEncode(cartItems);
    await setString(AppConstants.cartKey, jsonString);
  }

  static List<Map<String, dynamic>> getCartData() {
    final jsonString = getString(AppConstants.cartKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> clearCartData() async {
    await remove(AppConstants.cartKey);
  }

  // Address-specific methods
  static Future<void> setSavedAddresses(List<Map<String, dynamic>> addresses) async {
    final jsonString = jsonEncode(addresses);
    await setString(AppConstants.addressKey, jsonString);
  }

  static List<Map<String, dynamic>> getSavedAddresses() {
    final jsonString = getString(AppConstants.addressKey);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // Location-specific methods
  static Future<void> setUserLocation(Map<String, dynamic> location) async {
    await setJson(AppConstants.locationKey, location);
    await setString(AppConstants.lastLocationUpdateKey, DateTime.now().toIso8601String());
  }

  static Map<String, dynamic>? getUserLocation() {
    return getJson(AppConstants.locationKey);
  }

  static DateTime? getLastLocationUpdate() {
    final updateString = getString(AppConstants.lastLocationUpdateKey);
    if (updateString != null) {
      try {
        return DateTime.parse(updateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUserLocation() async {
    await remove(AppConstants.locationKey);
    await remove(AppConstants.lastLocationUpdateKey);
  }

  // Logout method
  static Future<void> logout() async {
    await removeAuthToken();
    await removeUserData();
    await clearCartData();
  }
}