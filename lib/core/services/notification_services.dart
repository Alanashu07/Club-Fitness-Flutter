// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tz;

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   bool _isAppInForeground = false;

//   /// Call this from your AppLifecycleListener or WidgetsBindingObserver
//   void setForegroundState(bool isForeground) {
//     _isAppInForeground = isForeground;
//   }

//   Future<void> init() async {
//     tz.initializeTimeZones();

//     // Set local timezone (change to your timezone string)
//     tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _plugin.initialize(
//       settings: initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//       onDidReceiveBackgroundNotificationResponse:
//           _onBackgroundNotificationTapped,
//     );

//     // Request permissions
//     await _requestPermissions();
//   }

//   Future<void> _requestPermissions() async {
//     // Android 13+
//     final androidPlugin = _plugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >();
//     await androidPlugin?.requestNotificationsPermission();
//     await androidPlugin?.requestExactAlarmsPermission();

//     // iOS
//     final iosPlugin = _plugin
//         .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin
//         >();
//     await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
//   }

//   Future<AndroidNotificationDetails> _buildAndroidDetails({
//     String? localImagePath,
//   }) async {
//     StyleInformation? styleInformation;

//     if (localImagePath != null) {
//       final bigPicture = FilePathAndroidBitmap(localImagePath);
//       styleInformation = BigPictureStyleInformation(bigPicture);
//     }

//     return AndroidNotificationDetails(
//       'scheduled_channel',
//       'Scheduled Notifications',
//       channelDescription: 'Channel for scheduled notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       styleInformation: styleInformation,
//     );
//   }

//   Future<DarwinNotificationDetails> _buildIOSDetails({
//     String? localImagePath,
//   }) async {
//     String? attachmentPath = localImagePath;

//     return DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       attachments: attachmentPath != null
//           ? [DarwinNotificationAttachment(attachmentPath)]
//           : null,
//     );
//   }

//   /// Schedule a notification at a specific DateTime
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//     String? localImagePath, // local file path
//   }) async {
//     if (_isAppInForeground) return;

//     final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

//     final androidDetails = await _buildAndroidDetails(
//       localImagePath: localImagePath,
//     );
//     final iosDetails = await _buildIOSDetails(localImagePath: localImagePath);

//     final details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _plugin.zonedSchedule(
//       id: id,
//       title: title,
//       body: body,
//       scheduledDate: tzScheduledDate,
//       notificationDetails: details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   /// Schedule a notification after a Duration from now
//   Future<void> scheduleNotificationAfterDuration({
//     required int id,
//     required String title,
//     required String body,
//     required Duration delay,
//     String? localPath,
//   }) async {
//     final scheduledDate = DateTime.now().add(delay);
//     await scheduleNotification(
//       id: id,
//       title: title,
//       body: body,
//       scheduledDate: scheduledDate,
//       localImagePath: localPath,
//     );
//   }

//   /// Schedule a repeating notification (daily, weekly, etc.)
//   Future<void> scheduleRepeatingNotification({
//     required int id,
//     required String title,
//     required String body,
//     required RepeatInterval repeatInterval,
//   }) async {
//     if (_isAppInForeground) return;

//     const androidDetails = AndroidNotificationDetails(
//       'repeating_channel',
//       'Repeating Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: DarwinNotificationDetails(),
//     );

//     await _plugin.periodicallyShow(
//       id: id,
//       title: title,
//       body: body,
//       repeatInterval: repeatInterval,
//       notificationDetails: details,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   /// Cancel a specific notification
//   Future<void> cancelNotification(int id) async {
//     await _plugin.cancel(id: id);
//   }

//   /// Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _plugin.cancelAll();
//   }

//   /// Get all pending scheduled notifications
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _plugin.pendingNotificationRequests();
//   }
// }

// // Must be top-level function
// @pragma('vm:entry-point')
// void _onBackgroundNotificationTapped(NotificationResponse response) {
//   // Handle background tap
// }

// void _onNotificationTapped(NotificationResponse response) {
//   // Handle foreground tap
// }
