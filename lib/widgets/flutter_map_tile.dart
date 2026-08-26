// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:club_fitness/core/themes/theme.dart';

// class FlutterMapTile extends StatelessWidget {
//   final double lat, lng, height, curveRadius, initialZoom;
//   const FlutterMapTile({
//     super.key,
//     required this.lat,
//     required this.lng,
//     this.height = 200,
//     this.curveRadius = 14,
//     this.initialZoom = 14,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(curveRadius),
//       child: SizedBox(
//         height: height,
//         child: FlutterMap(
//           options: MapOptions(
//             initialCenter: LatLng(lat, lng),
//             initialZoom: initialZoom,
//             interactionOptions: const InteractionOptions(
//               flags: InteractiveFlag.none,
//             ),
//           ),
//           children: [
//             TileLayer(
//               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//               userAgentPackageName: 'com.livista360.club_fitness.app',
//             ),
//             MarkerLayer(
//               markers: [
//                 Marker(
//                   point: LatLng(lat, lng),
//                   width: 50,
//                   height: 60,
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [RColors.primary, RColors.accent],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: RColors.primary.withAlpha(
//                                 (0.4 * 255).round(),
//                               ),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.place_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                       Container(
//                         width: 2,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               RColors.primary,
//                               RColors.primary.withAlpha(0),
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
