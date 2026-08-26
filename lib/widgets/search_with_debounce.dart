// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:club_fitness/config/navigation/routes_class.dart';
// import 'package:club_fitness/core/utils/utils.dart';

// class SearchWithDebounce extends StatefulWidget {
//   final String? hintText;
//   final void Function(String? query) onSearch;
//   final TextEditingController? controller;
//   final int debounceTimerInMs;
//   const SearchWithDebounce({
//     super.key,
//     this.hintText,
//     required this.onSearch,
//     this.controller,
//     this.debounceTimerInMs = 500,
//   });

//   @override
//   State<SearchWithDebounce> createState() => _SearchWithDebounceState();
// }

// class _SearchWithDebounceState extends State<SearchWithDebounce> {
//   Timer? _debounceTimer;

//   void _onSearch(String? query) {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(
//       Duration(milliseconds: widget.debounceTimerInMs),
//       () {
//         widget.onSearch(query);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//       decoration: BoxDecoration(
//         color: RColors.cardBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: RColors.cardBorder),
//         boxShadow: [
//           BoxShadow(
//             color: RColors.primary.withAlphaOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: RColors.primaryLight,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.search_rounded,
//               color: RColors.primary,
//               size: 17,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: widget.hintText,
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//                 hintStyle: const TextStyle(
//                   fontSize: 13,
//                   color: RColors.textMuted,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               onChanged: _onSearch,
//               controller: widget.controller,
//               onSubmitted: widget.onSearch,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: RColors.primaryLight,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'Explore',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//                 color: RColors.primary,
//                 letterSpacing: 0.4,
//               ),
//             ),
//           ).onTap(
//             onTap: () => context.push(
//               '${RoutesName.explore}${widget.controller?.text.isNotEmpty ?? false ? '?query=${widget.controller?.text}' : ''}',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
