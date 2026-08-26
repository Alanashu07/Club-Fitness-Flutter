// import 'dart:convert';
// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:http/http.dart' as http;
// import 'package:club_fitness/config/local/app_data.dart';
// import 'package:club_fitness/config/network/api.dart';
// import 'package:club_fitness/core/exceptions/status_codes.dart';
// import 'package:club_fitness/firebase_options.dart';

// class FirebaseServices {
//   static final FirebaseMessaging fcm = FirebaseMessaging.instance;

//   static Future<String> getUserFCMToken() async {
//     await fcm.requestPermission();
//     final token = await fcm.getToken();
//     await AppData().storeFcmToken(token!);
//     return token;
//   }

//   static Future<String> getAccessToken() async {
//     final servicesAccountJson = {};

//     List<String> scopes = [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging",
//     ];

//     http.Client client = await auth.clientViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(servicesAccountJson),
//       scopes,
//     );

//     auth.AccessCredentials credentials = await auth
//         .obtainAccessCredentialsViaServiceAccount(
//           auth.ServiceAccountCredentials.fromJson(servicesAccountJson),
//           scopes,
//           client,
//         );

//     client.close();
//     return credentials.accessToken.data;
//   }

//   static Future<void> sendTestNotification({
//     required num userId,
//     required String title,
//     required String body,
//     String? imageUrl,
//     Map<String, dynamic> data = const {},
//   }) async {
//     try {
//       final formData = {
//         "user_id": userId,
//         "title": title,
//         "body": body,
//         "image": imageUrl,
//         "data": data,
//       };
//       DioResponse response = await DioConfig().dioPostCall(
//         "EndPoints.sendTestNotification",
//         formData,
//       );
//       if (response.hasError) {
//         throw StatusCodes.errorFromCodeOrType(
//           response.dioError.response?.statusCode,
//           response.dioError.type,
//         );
//       }
//     } catch (e, s) {
//       log(e.toString(), error: e, stackTrace: s);
//     }
//   }

//   static Future<void> sendPushNotification({
//     required String token,
//     required String title,
//     required String body,
//     String? imageUrl,
//   }) async {
//     try {
//       final String serverKey = await getAccessToken();
//       String fcmUrl =
//           'https://fcm.googleapis.com/v1/projects/${DefaultFirebaseOptions.currentPlatform.projectId}/messages:send';

//       final Map<String, dynamic> notification = {
//         'message': {
//           'token': token,
//           'notification': {
//             'title': title,
//             'body': body,
//             if (imageUrl != null) 'image': imageUrl,
//           },
//           'android': {
//             'priority': 'HIGH',
//             'notification': {if (imageUrl != null) 'image': imageUrl},
//           },
//           'apns': {
//             'headers': {'apns-priority': '10'},
//             'payload': {
//               'aps': {
//                 'content-available': 1,
//                 'alert': {'title': title, 'body': body},
//               },
//             },
//           },
//           'data': {'type': "TEST"},
//         },
//       };

//       final response = await http.post(
//         Uri.parse(fcmUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $serverKey',
//         },
//         body: jsonEncode(notification),
//       );
//       log("FCM Status: ${response.statusCode}");
//       log("FCM Response: ${response.body}");
//     } catch (e, s) {
//       log(e.toString(), error: e, stackTrace: s);
//     }
//   }
// }
