import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  static final AppData appData = AppData._();

  late SharedPreferences _appData;

  factory AppData() => appData;

  AppData._();

  Future<void> initStorage() async {
    _appData = await SharedPreferences.getInstance();
  }

  // Store Auth TOKENS

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String rotationTokenKey = 'rotation_token';

  Future<bool> storeAccessToken(String accessToken) async {
    return await _appData.setString(accessTokenKey, accessToken);
  }

  Future<bool> storeRefreshToken(String refreshToken) async {
    return await _appData.setString(refreshTokenKey, refreshToken);
  }

  Future<bool> storeRotationToken(String rotationToken) async {
    return await _appData.setString(rotationTokenKey, rotationToken);
  }

  String getAccessToken() => _appData.getString(accessTokenKey) ?? '';
  String getRefreshToken() => _appData.getString(refreshTokenKey) ?? '';
  String getRotationToken() => _appData.getString(rotationTokenKey) ?? '';

  static String get accessTokenValue => appData.getAccessToken();
  static String get refreshTokenValue => appData.getRefreshToken();
  static String get rotationTokenValue => appData.getRotationToken();

  static Future<({bool access, bool refresh, bool rotation})>
  storeTokens(String accessToken, String refreshToken, String rotationToken) async {
    return (
      access: await appData.storeAccessToken(accessToken),
      refresh: await appData.storeRefreshToken(refreshToken),
      rotation: await appData.storeRotationToken(rotationToken),
    );
  }

  //clear values

  Future<bool> clearValues() async {
    return await _appData.clear();
  }

  Future<bool> clearKey(String key) async {
    return await _appData.remove(key);
  }
}
