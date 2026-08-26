// import 'package:flutter/material.dart';
// import 'package:club_fitness/config/local/app_data.dart';

// class FixedTimeWidget extends StatefulWidget {
//   final Widget child;
//   final String widgetKey;
//   final Duration duration;
//   final Widget expiredWidget;

//   const FixedTimeWidget({
//     super.key,
//     required this.child,
//     required this.widgetKey,
//     required this.duration,
//     this.expiredWidget = const SizedBox.shrink(),
//   });

//   @override
//   State<FixedTimeWidget> createState() => _FixedTimeWidgetState();
// }

// class _FixedTimeWidgetState extends State<FixedTimeWidget> {
//   bool showChild = true;

//   void _getValues() async {
//     int value = AppData().getInt(widget.widgetKey);
//     if (value == 0) {
//       await AppData().storeInt(
//         widget.widgetKey,
//         DateTime.now().millisecondsSinceEpoch,
//       );
//       setState(() {
//         showChild = true;
//       });
//     } else {
//       if (DateTime.now().millisecondsSinceEpoch - value >
//           widget.duration.inMilliseconds) {
//         setState(() {
//           showChild = false;
//         });
//         return;
//       }
//       setState(() {
//         showChild = true;
//       });
//     }
//   }

//   @override
//   void initState() {
//     _getValues();
//     super.initState();
//   }

//   @override
//   void didUpdateWidget(covariant FixedTimeWidget oldWidget) {
//     _getValues();
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return showChild ? widget.child : widget.expiredWidget;
//   }
// }
