// import 'package:flutter/material.dart';
// import 'package:club_fitness/config/navigation/routes_class.dart';
// import 'package:club_fitness/core/constants/constants.dart';
// import 'package:club_fitness/core/themes/light_theme.dart';
// import 'package:club_fitness/core/themes/theme.dart';
// import 'package:club_fitness/widgets/common_widgets.dart';

// export 'package:club_fitness/features/map/presentation/screens/map_view.dart';

// class _TabItem {
//   final IconData activeIcon, inactiveIcon;
//   final String label;
//   final String? route;
//   const _TabItem({
//     required this.activeIcon,
//     required this.inactiveIcon,
//     required this.label,
//     this.route,
//   });
// }

// class BottomBar extends StatefulWidget {
//   final int tab;
//   final MapType mapType;
//   const BottomBar({super.key, required this.tab, required this.mapType});

//   @override
//   State<BottomBar> createState() => _BottomBarState();
// }

// class _BottomBarState extends State<BottomBar> {
//   int get _tab => widget.tab;
//   final _tabs = const [
//     _TabItem(
//       activeIcon: Icons.home_rounded,
//       inactiveIcon: Icons.home_outlined,
//       label: 'Home',
//     ),
//     _TabItem(
//       activeIcon: Icons.people_rounded,
//       inactiveIcon: Icons.people_outline,
//       label: 'Feed',
//       route: RoutesName.userFeed,
//     ),
//     _TabItem(
//       activeIcon: Icons.map_rounded,
//       inactiveIcon: Icons.map_outlined,
//       label: 'Map',
//     ),
//     _TabItem(
//       activeIcon: Icons.explore_rounded,
//       inactiveIcon: Icons.explore_outlined,
//       label: 'Explore',
//       route: RoutesName.explore,
//     ),
//     // _TabItem(
//     //   activeIcon: Icons.person_rounded,
//     //   inactiveIcon: Icons.person_outline,
//     //   label: 'Profile',
//     //   route: RoutesName.profile,
//     // ),
//     _TabItem(
//       activeIcon: FlaticonRoundedIcons.srBriefcase,
//       inactiveIcon: Flaticon.rrBriefcase,
//       label: 'My Trips',
//       route: RoutesName.myTrips,
//     ),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     final pad = MediaQuery.of(context).padding.bottom;
//     return Container(
//       padding: EdgeInsets.only(bottom: pad + 8, top: 8, left: 12, right: 12),
//       decoration: const BoxDecoration(
//         color: RColors.cardBg,
//         border: Border(top: BorderSide(color: RColors.cardBorder, width: 1)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(_tabs.length, (i) {
//           final tab = _tabs[i];
//           final isActive = i == _tab;
//           if (i == 2) {
//             return GestureDetector(
//               onTap: () {
//                 if (isActive) return;
//                 context.push('${RoutesName.map}/${widget.mapType.name}');
//               },
//               child: CompassWidget(
//                 child: Container(
//                   width: 50,
//                   height: 50,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: const LinearGradient(
//                       colors: [RColors.primary, RColors.accent],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: RColors.textPrimary.withAlphaOpacity(0.4),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Image.asset(
//                     AssetConstants.compass,
//                     color: Colors.white,
//                     height: 38,
//                     width: 38,
//                     errorBuilder: (context, error, stackTrace) => Icon(
//                       isActive ? tab.activeIcon : tab.inactiveIcon,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                   ),
//                   // child: Icon(
//                   //   isActive ? tab.activeIcon : tab.inactiveIcon,
//                   //   color: Colors.white,
//                   //   size: 22,
//                   // ),
//                 ),
//               ),
//             );
//           }
//           return GestureDetector(
//             onTap: () {
//               if (isActive) return;
//               if (tab.route != null) {
//                 if (tab.route == RoutesName.userFeed) {
//                   context.go(tab.route!);
//                 } else {
//                   context.push(tab.route!);
//                 }
//                 return;
//               }
//               context.go(RoutesName.home);
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: isActive
//                     ? RColors.primary.withAlphaOpacity(0.12)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     isActive ? tab.activeIcon : tab.inactiveIcon,
//                     color: isActive
//                         ? RColors.primary
//                         : RColors.textSecondary.withAlphaOpacity(0.5),
//                     size: 22,
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     tab.label,
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w600,
//                       color: isActive
//                           ? RColors.primary
//                           : RColors.textSecondary.withAlphaOpacity(0.4),
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
