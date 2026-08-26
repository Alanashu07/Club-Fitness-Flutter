import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';

class UrlServices {
  static Future<void> launchSchemeUrl({
    required String scheme,
    required String path,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      Uri uri = Uri(scheme: scheme, path: path, queryParameters: queryParams);
      launchUrl(uri);
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> launchRegularUrl(String url) async {
    try {
      Uri uri = Uri.parse(url);
      launchUrl(uri);
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> whatsappNumber(String number) async {
    await launchSchemeUrl(scheme: 'https', path: 'wa.me/$number');
  }
}
