import 'dart:io';
import 'package:club_fitness/config/local/app_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/my_app.dart';
import 'di.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 1));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // _setupFirebaseListener();
  executeErrorInDebug(false);
  await AppData().initStorage();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();

    // Set the database factory for Windows
    databaseFactory = databaseFactoryFfi;
  }
  initDep();
  // _initDeepLinks();
  runApp(const MyApp());
}

// Future<void> _initDeepLinks() async {
//   AppLinks appLinks = AppLinks();

//   final Uri? initialUri = await appLinks.getInitialLink();
//   _handleDeepLink(initialUri);

//   appLinks.uriLinkStream.listen(_handleDeepLink);
// }

// void _handleDeepLink(Uri? uri) {
//   if (uri == null) return;
//   final router = RoutesClass.router;
//   return router.go(uri.path);
// }

// Future<void> _setupFirebaseListener() async {
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   _handleNotificationTap(initialMessage);

//   FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
// }

// void _handleNotificationTap(RemoteMessage? message) {
//   if (message == null) return;
//   if (message.data['url'] == null) return;
//   String? url = message.data['url'];
//   if (url == null) return;
//   String path = url.stripBase();
//   final router = RoutesClass.router;
//   return router.go(path);
// }

void executeErrorInDebug(bool showOnDevice) {
  if (!kDebugMode || !showOnDevice) return;
  FlutterError.onError = (FlutterErrorDetails details) {
    final error = details
        .exceptionAsString(); // Get the error message as a string

    // Check for specific errors to exclude
    if (error.contains('RenderFlex') || error.contains('HttpException')) {
      // Log the excluded errors or handle them separately
      debugPrint('Excluded Error: $error');
      return; // Skip custom error handling for these errors
    }
    FlutterError.dumpErrorToConsole(details);
    runApp(ErrorWidgetClass(errorDetails: details));
  };
}

class ErrorWidgetClass extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorWidgetClass({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Livista360 Error',
      home: CustomErrorWidget(
        errorMessage:
            '${errorDetails.exceptionAsString()}\n${errorDetails.stack.toString()}\n${errorDetails.exception.toString()}',
      ),
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;

  const CustomErrorWidget({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 15),
            const Text(
              "Error Occurred!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            SelectableText(errorMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Clipboard.setData(ClipboardData(text: errorMessage)),
        label: const Text("Copy"),
        icon: const Icon(Icons.copy),
      ),
    );
  }
}
