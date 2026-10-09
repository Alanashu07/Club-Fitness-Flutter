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

  static Future<void> whatsappMessage({
  required String number,
  String? message,
}) async {
  try {
    final uri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: number,
      queryParameters: message == null ? null : {'text': message},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    log(e.toString());
  }
}
}
