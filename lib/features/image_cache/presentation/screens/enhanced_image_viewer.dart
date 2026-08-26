// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// import 'package:club_fitness/config/network/api.dart';
// import 'package:club_fitness/core/constants/constants.dart';
// import 'package:club_fitness/config/theme/theme.dart';
// import 'package:club_fitness/core/utils/utils.dart';
// import 'package:club_fitness/features/image_cache/image_cache.dart';

// // ─────────────────────────────────────────────────────────────
// // Data model
// // ─────────────────────────────────────────────────────────────
// class ClubFitnessImageItem {
//   final String imageUrl;
//   final String? title;
//   final String? caption;
//   final List<String> tags;

//   const ClubFitnessImageItem({
//     required this.imageUrl,
//     this.title,
//     this.caption,
//     this.tags = const [],
//   });
// }

// // ─────────────────────────────────────────────────────────────
// // ClubFitnessImageViewer  — entry point
// // ─────────────────────────────────────────────────────────────
// class ClubFitnessImageViewer extends StatefulWidget {
//   final List<ClubFitnessImageItem> images;
//   final int initialIndex;

//   /// Optional hero tag prefix; each image uses "$heroTagPrefix_$index"
//   final String? heroTagPrefix;

//   const ClubFitnessImageViewer({
//     super.key,
//     required this.images,
//     this.initialIndex = 0,
//     this.heroTagPrefix,
//   });

//   /// Convenience: open in a full-screen route
//   static Future<void> open(
//     BuildContext context, {
//     required List<ClubFitnessImageItem> images,
//     int initialIndex = 0,
//     String? heroTagPrefix,
//   }) {
//     return Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         barrierColor: Colors.transparent,
//         pageBuilder: (_, __, ___) => ClubFitnessImageViewer(
//           images: images,
//           initialIndex: initialIndex,
//           heroTagPrefix: heroTagPrefix,
//         ),
//         transitionsBuilder: (_, anim, __, child) =>
//             FadeTransition(opacity: anim, child: child),
//         transitionDuration: const Duration(milliseconds: 280),
//       ),
//     );
//   }

//   @override
//   State<ClubFitnessImageViewer> createState() =>
//       _ClubFitnessImageViewerState();
// }

// class _ClubFitnessImageViewerState extends State<ClubFitnessImageViewer>
//     with TickerProviderStateMixin {
//   late PageController _pageCtrl;
//   late int _current;

//   // Panel animation
//   late AnimationController _panelCtrl;
//   late Animation<Offset> _panelSlide;
//   bool _showPanel = true;

//   // Background fade
//   late AnimationController _bgCtrl;
//   late Animation<double> _bgOpacity;

//   // Per-page transform (zoom + pan)
//   final Map<int, _TransformState> _transforms = {};
//   List<String?> downloadedImages = [];

//   void _getImages() async {
//     for (final image in widget.images) {
//       String? imageUrl;
//       imageUrl = await image.imageUrl.imagePath;
//       setState(() {
//         downloadedImages.add(imageUrl);
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getImages();
//     _current = widget.initialIndex;
//     _pageCtrl = PageController(initialPage: _current);

//     _panelCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 320),
//     );
//     _panelSlide = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0, 1),
//     ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeInOut));

//     _bgCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//       value: 1,
//     );
//     _bgOpacity = _bgCtrl.drive(Tween<double>(begin: 0, end: 1));

//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageCtrl.dispose();
//     _panelCtrl.dispose();
//     _bgCtrl.dispose();
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//     );
//     super.dispose();
//   }

//   _TransformState _stateFor(int index) =>
//       _transforms.putIfAbsent(index, () => _TransformState());

//   void _togglePanel() {
//     setState(() => _showPanel = !_showPanel);
//     if (_showPanel) {
//       _panelCtrl.reverse();
//     } else {
//       _panelCtrl.forward();
//     }
//   }

//   void _close() {
//     _bgCtrl.reverse().then((_) {
//       if (mounted) Navigator.of(context).pop();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = context.mq.viewInsets.bottom;
//     final item = widget.images[_current];
//     final hasMeta =
//         (item.title?.isNotEmpty ?? false) ||
//         (item.caption?.isNotEmpty ?? false) ||
//         item.tags.isNotEmpty;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.light,
//         statusBarColor: Colors.transparent,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: AnimatedBuilder(
//           animation: _bgOpacity,
//           builder: (_, child) => ColoredBox(
//             color: Colors.black.withAOpacity(0.93 * _bgOpacity.value),
//             child: child,
//           ),
//           child: Stack(
//             children: [
//               // ── Page view ─────────────────────────────────
//               GestureDetector(
//                 onTap: hasMeta ? _togglePanel : null,
//                 child: PhotoViewGallery.builder(
//                   backgroundDecoration: const BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                   pageController: _pageCtrl,
//                   itemCount: downloadedImages.length,
//                   onPageChanged: (index) => setState(() => _current = index),
//                   builder: (_, index) {
//                     return PhotoViewGalleryPageOptions(
//                       imageProvider: FileImage(
//                         File(downloadedImages[index] ?? ''),
//                       ),
//                       errorBuilder: EndPoints.isProduction
//                           ? null
//                           : (context, error, stackTrace) =>
//                                 Center(child: Text(error.toString())),
//                       minScale: PhotoViewComputedScale.contained * 0.8,
//                       maxScale: PhotoViewComputedScale.covered * 2.0,
//                       initialScale: PhotoViewComputedScale.contained,
//                     );
//                   },
//                 ),
//                 // child: PageView.builder(
//                 //   controller: _pageCtrl,
//                 //   itemCount: widget.images.length,
//                 //   onPageChanged: (i) => setState(() => _current = i),
//                 //   itemBuilder: (_, i) => _ZoomablePage(
//                 //     key: ValueKey(i),
//                 //     image: widget.images[i],
//                 //     heroTag: widget.heroTagPrefix != null
//                 //         ? '${widget.heroTagPrefix}_$i'
//                 //         : null,
//                 //     transformState: _stateFor(i),
//                 //   ),
//                 // ),
//               ),

//               // ── Top bar ───────────────────────────────────
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: _TopBar(
//                   current: _current,
//                   total: widget.images.length,
//                   onClose: _close,
//                 ),
//               ),

//               // ── Dot indicator (multi-image) ───────────────
//               if (widget.images.length > 1)
//                 Positioned(
//                   bottom: (hasMeta ? 220 : 40) + bottomInset,
//                   left: 0,
//                   right: 0,
//                   child: _DotIndicator(
//                     count: widget.images.length,
//                     current: _current,
//                   ),
//                 ),

//               // ── Arrow navigation ──────────────────────────
//               if (widget.images.length > 1) ...[
//                 if (_current > 0)
//                   Positioned(
//                     left: 8,
//                     top: 0,
//                     bottom: bottomInset,
//                     child: Center(
//                       child: _NavArrow(
//                         icon: Icons.chevron_left_rounded,
//                         onTap: () => _pageCtrl.previousPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         ),
//                       ),
//                     ),
//                   ),
//                 if (_current < widget.images.length - 1)
//                   Positioned(
//                     right: 8,
//                     top: 0,
//                     bottom: bottomInset,
//                     child: Center(
//                       child: _NavArrow(
//                         icon: Icons.chevron_right_rounded,
//                         onTap: () => _pageCtrl.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],

//               // ── Bottom info panel ─────────────────────────
//               if (hasMeta)
//                 Positioned(
//                   bottom: bottomInset,
//                   left: 0,
//                   right: 0,
//                   child: SlideTransition(
//                     position: _panelSlide,
//                     child: _InfoPanel(item: item),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Top bar
// // ─────────────────────────────────────────────────────────────
// class _TopBar extends StatelessWidget {
//   final int current;
//   final int total;
//   final VoidCallback onClose;

//   const _TopBar({
//     required this.current,
//     required this.total,
//     required this.onClose,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 8,
//         left: 12,
//         right: 12,
//         bottom: 12,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.black.withAOpacity(0.65), Colors.transparent],
//         ),
//       ),
//       child: Row(
//         children: [
//           // Close
//           _CircleBtn(icon: Icons.close_rounded, onTap: onClose),
//           const Spacer(),
//           // Counter pill
//           if (total > 1)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//               decoration: BoxDecoration(
//                 color: AppTheme.primary.withAOpacity(0.75),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.white.withAOpacity(0.2),
//                   width: 0.8,
//                 ),
//               ),
//               child: Text(
//                 '${current + 1} / $total',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Circle button helper
// // ─────────────────────────────────────────────────────────────
// class _CircleBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _CircleBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 38,
//         height: 38,
//         decoration: BoxDecoration(
//           color: Colors.black.withAOpacity(0.45),
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: Colors.white.withAOpacity(0.18),
//             width: 0.8,
//           ),
//         ),
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Nav arrow
// // ─────────────────────────────────────────────────────────────
// class _NavArrow extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _NavArrow({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: Colors.black.withAOpacity(0.4),
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: Colors.white.withAOpacity(0.15),
//             width: 0.8,
//           ),
//         ),
//         child: Icon(icon, color: Colors.white.withAOpacity(0.85), size: 22),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Dot indicator
// // ─────────────────────────────────────────────────────────────
// class _DotIndicator extends StatelessWidget {
//   final int count;
//   final int current;

//   const _DotIndicator({required this.count, required this.current});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(count > 10 ? 10 : count, (i) {
//         final isActive = i == (current > 9 ? 9 : current);
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 260),
//           curve: Curves.easeOut,
//           margin: const EdgeInsets.symmetric(horizontal: 3),
//           width: isActive ? 18 : 6,
//           height: 6,
//           decoration: BoxDecoration(
//             color: isActive
//                 ? AppTheme.primary
//                 : Colors.white.withAOpacity(0.45),
//             borderRadius: BorderRadius.circular(3),
//           ),
//         );
//       }),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Info panel
// // ─────────────────────────────────────────────────────────────
// class _InfoPanel extends StatelessWidget {
//   final ClubFitnessImageItem item;

//   const _InfoPanel({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppTheme.card,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         border: Border.all(color: AppTheme.cardBorder),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primary.withAOpacity(0.10),
//             blurRadius: 24,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Drag handle
//           Center(
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppTheme.divider,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Title
//                 if (item.title?.isNotEmpty ?? false) ...[
//                   Row(
//                     children: [
//                       Container(
//                         width: 3,
//                         height: 18,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [AppTheme.primary, AppTheme.secondary],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           item.title!,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                 ],

//                 // Caption
//                 if (item.caption?.isNotEmpty ?? false) ...[
//                   Text(
//                     item.caption!,
                    
//                     maxLines: 4,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 12),
//                 ],

//                 // Tags
//                 if (item.tags.isNotEmpty) ...[
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: 6,
//                     children: item.tags
//                         .map((tag) => _TagChip(label: tag))
//                         .toList(),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Tag chip
// // ─────────────────────────────────────────────────────────────
// class _TagChip extends StatelessWidget {
//   final String label;

//   const _TagChip({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: AppTheme.secondary,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppTheme.cardBorder),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.tag, size: 10, color: AppTheme.primary),
//           const SizedBox(width: 3),
//           Text(
//             label,
//             style: RTextStyles.tag.copyWith(fontSize: 10, letterSpacing: 0.5),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────
// // Zoomable page  (pinch-to-zoom + double-tap)
// // ─────────────────────────────────────────────────────────────
// class _TransformState {
//   double scale = 1.0;
//   Offset offset = Offset.zero;
// }

// class _ZoomablePage extends StatefulWidget {
//   final ClubFitnessImageItem image;
//   final String? heroTag;
//   final _TransformState transformState;

//   const _ZoomablePage({
//     super.key,
//     required this.image,
//     required this.transformState,
//     this.heroTag,
//   });

//   @override
//   State<_ZoomablePage> createState() => _ZoomablePageState();
// }

// class _ZoomablePageState extends State<_ZoomablePage>
//     with SingleTickerProviderStateMixin {
//   late TransformationController _transformCtrl;
//   late AnimationController _animCtrl;
//   Animation<Matrix4>? _animation;

//   static const _minScale = 1.0;
//   static const _maxScale = 4.0;
//   static const _doubleTapScale = 2.5;

//   @override
//   void initState() {
//     super.initState();
//     _transformCtrl = TransformationController();
//     _animCtrl =
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 280),
//         )..addListener(() {
//           if (_animation != null) {
//             _transformCtrl.value = _animation!.value;
//           }
//         });
//   }

//   @override
//   void dispose() {
//     _transformCtrl.dispose();
//     _animCtrl.dispose();
//     super.dispose();
//   }

//   void _onDoubleTap(TapDownDetails details) {
//     final isZoomed =
//         _transformCtrl.value.getMaxScaleOnAxis() > _minScale + 0.01;

//     final Matrix4 target;
//     if (isZoomed) {
//       target = Matrix4.identity();
//     } else {
//       final pos = details.localPosition;
//       final x = -pos.dx * (_doubleTapScale - 1);
//       final y = -pos.dy * (_doubleTapScale - 1);
//       target = Matrix4.identity()
//         ..translate(x, y)
//         ..scale(_doubleTapScale);
//     }

//     _animation = Matrix4Tween(
//       begin: _transformCtrl.value,
//       end: target,
//     ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
//     _animCtrl.forward(from: 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget imageWidget = Image.network(
//       widget.image.imageUrl,
//       fit: BoxFit.contain,
//       loadingBuilder: (_, child, progress) {
//         if (progress == null) return child;
//         return Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: CircularProgressIndicator(
//                   value: progress.expectedTotalBytes != null
//                       ? progress.cumulativeBytesLoaded /
//                             progress.expectedTotalBytes!
//                       : null,
//                   color: AppTheme.primary,
//                   strokeWidth: 2.5,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Loading image…',
//                 style: RTextStyles.label.copyWith(color: Colors.white54),
//               ),
//             ],
//           ),
//         );
//       },
//       errorBuilder: (_, __, ___) => Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: BoxDecoration(
//                 color: AppTheme.surface.withAOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.broken_image_rounded,
//                 color: AppTheme.primaryDim,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Image unavailable',
//               style: RTextStyles.label.copyWith(color: Colors.white54),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (widget.heroTag != null) {
//       imageWidget = Hero(tag: widget.heroTag!, child: imageWidget);
//     }

//     return GestureDetector(
//       onDoubleTapDown: _onDoubleTap,
//       onDoubleTap: () {},
//       child: InteractiveViewer(
//         transformationController: _transformCtrl,
//         minScale: _minScale,
//         maxScale: _maxScale,
//         clipBehavior: Clip.none,
//         child: Center(child: imageWidget),
//       ),
//     );
//   }
// }
