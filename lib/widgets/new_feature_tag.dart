// import 'package:flutter/material.dart';
// import 'package:club_fitness/core/constants/constants.dart';
// import 'package:club_fitness/core/utils/utils.dart';
// import 'package:club_fitness/widgets/common_widgets.dart';

// import '../../data/local/app_data.dart';

// class FeatureOffset {
//   final double? top;
//   final double? right;
//   final double? bottom;
//   final double? left;

//   const FeatureOffset({this.top = -3, this.right = -3, this.bottom, this.left});
// }

// class NewFeatureTag extends StatefulWidget {
//   final Widget child;
//   final Color backgroundColor;
//   final Color textColor;
//   final String widgetKey;
//   final Duration? duration;
//   final FeatureOffset offset;
//   final BorderRadius? borderRadius;
//   final double? fontSize;
//   final bool disappearOnClick;

//   ///On pressed will only work if [disappearOnClick] is true.
//   ///
//   ///Use InkWell or GestureDetector otherwise
//   final VoidCallback? onPressed;
//   final StackFit fit;

//   const NewFeatureTag({
//     super.key,
//     required this.child,
//     this.backgroundColor = Colors.green,
//     this.textColor = Colors.white,
//     this.duration = const Duration(days: 7),
//     required this.widgetKey,
//     this.offset = const FeatureOffset(),
//     this.borderRadius,
//     this.fontSize,
//     this.disappearOnClick = false,
//     this.onPressed,
//     this.fit = StackFit.loose,
//   });

//   @override
//   State<NewFeatureTag> createState() => _NewFeatureTagState();
// }

// class _NewFeatureTagState extends State<NewFeatureTag> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: !widget.disappearOnClick
//           ? null
//           : () async {
//               if (widget.duration == null) {
//                 widget.onPressed?.call();
//                 return;
//               }
//               String key = widget.widgetKey;
//               DateTime savedAt = DateTime.fromMillisecondsSinceEpoch(
//                 AppData().getInt(key),
//               );
//               bool showChild = savedAt.isAfter(
//                 DateTime.now().subtract(widget.duration!),
//               );
//               if (showChild) {
//                 await AppData().storeInt(
//                   key,
//                   DateTime.now()
//                       .subtract(widget.duration! + 1.day)
//                       .millisecondsSinceEpoch,
//                 );
//                 if (mounted) {
//                   setState(() {});
//                 }
//               }
//               widget.onPressed?.call();
//             },
//       child: Stack(
//         clipBehavior: Clip.none,
//         fit: widget.fit,
//         children: [
//           widget.child,
//           if (widget.duration != null)
//             FixedTimeWidget(
//               duration: widget.duration!,
//               widgetKey: widget.widgetKey,
//               child: Positioned(
//                 top: widget.offset.top,
//                 right: widget.offset.right,
//                 bottom: widget.offset.bottom,
//                 left: widget.offset.left,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: widget.backgroundColor,
//                     borderRadius:
//                         widget.borderRadius ??
//                         const BorderRadius.only(
//                           topRight: Radius.circular(12),
//                           bottomLeft: Radius.circular(12),
//                         ),
//                   ),
//                   child: TextWidget(
//                     'New',
//                     fontSize: widget.fontSize,
//                     color: widget.textColor,
//                     style: FontConstant.oxygenSmallBold,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
