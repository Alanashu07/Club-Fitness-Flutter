// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:club_fitness/core/services/video_thumbnail_helper.dart';
// import 'package:club_fitness/core/themes/light_theme.dart';
// import 'package:video_player/video_player.dart';
// import 'package:club_fitness/widgets/common_widgets.dart';
// import 'package:path/path.dart' as path;

// class VideoViewerScreen extends StatefulWidget {
//   final String videoPath;
//   final bool isNetwork;
//   final String? title;

//   const VideoViewerScreen({
//     super.key,
//     required this.videoPath,
//     required this.isNetwork,
//     this.title,
//   });

//   @override
//   State<VideoViewerScreen> createState() => _VideoViewerScreenState();
// }

// class _VideoViewerScreenState extends State<VideoViewerScreen>
//     with SingleTickerProviderStateMixin {
//   late VideoPlayerController _controller;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;

//   bool _isInitialized = false;
//   bool _isPlaying = false;
//   bool _showControls = true;
//   bool _isFullscreen = false;
//   String? _thumbnailPath;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     );
//     _fadeController.forward();

//     _extractThumbnail();
//     _initializePlayer();
//   }

//   Future<void> _extractThumbnail() async {
//     final path = await VideoThumbnailHelper.extractThumbnail(
//       videoPath: widget.videoPath,
//       width: 300,
//       height: 300,
//     );
//     setState(() => _thumbnailPath = path);
//   }

//   Future<void> _initializePlayer() async {
//     if (widget.isNetwork) {
//       _controller = VideoPlayerController.networkUrl(
//         Uri.parse(widget.videoPath),
//       );
//     } else {
//       _controller = VideoPlayerController.file(File(widget.videoPath));
//     }

//     try {
//       await _controller.initialize();
//       _controller.addListener(_onVideoUpdate);
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//           _duration = _controller.value.duration;
//         });
//       }
//     } catch (e) {
//       debugPrint('Video initialization failed: $e');
//     }
//   }

//   void _onVideoUpdate() {
//     if (!mounted) return;
//     setState(() {
//       _position = _controller.value.position;
//       _isPlaying = _controller.value.isPlaying;
//     });

//     // Auto-hide controls after 3s during playback
//     if (_controller.value.isPlaying) {
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted && _controller.value.isPlaying) {
//           setState(() => _showControls = false);
//         }
//       });
//     }
//   }

//   void _togglePlayPause() {
//     if (_controller.value.isPlaying) {
//       _controller.pause();
//     } else {
//       _controller.play();
//     }
//     setState(() => _showControls = true);
//   }

//   void _toggleControls() {
//     setState(() => _showControls = !_showControls);
//   }

//   void _onSliderChanged(double value) {
//     _controller.seekTo(Duration(milliseconds: value.toInt()));
//   }

//   void _skipForward() {
//     final newPos = _position + const Duration(seconds: 10);
//     _controller.seekTo(newPos > _duration ? _duration : newPos);
//   }

//   void _skipBackward() {
//     final newPos = _position - const Duration(seconds: 10);
//     _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
//   }

//   void _toggleFullscreen() {
//     setState(() => _isFullscreen = !_isFullscreen);
//     if (_isFullscreen) {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     } else {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     }
//   }

//   String _formatDuration(Duration d) {
//     final h = d.inHours;
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return h > 0 ? '$h:$m:$s' : '$m:$s';
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_onVideoUpdate);
//     _controller.dispose();
//     _fadeController.dispose();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//     // Clean up thumbnail
//     if (_thumbnailPath != null) {
//       File(_thumbnailPath!).exists().then((exists) {
//         if (exists) File(_thumbnailPath!).delete();
//       });
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScaffold(
//       backgroundColor: Colors.black,
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: _isFullscreen
//             ? _buildVideoArea()
//             : Column(children: [_buildVideoArea(), _buildVideoInfo()]),
//       ),
//     );
//   }

//   Widget _buildVideoArea() {
//     return Center(
//       child: AspectRatio(
//         aspectRatio: _isInitialized ? _controller.value.aspectRatio : 16 / 9,
//         child: GestureDetector(
//           onTap: _toggleControls,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Thumbnail shown before video is ready
//               if (!_isInitialized && _thumbnailPath != null)
//                 Image.file(
//                   File(_thumbnailPath!),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),

//               // Video player
//               if (_isInitialized) VideoPlayer(_controller),

//               // Loading indicator
//               if (!_isInitialized)
//                 const CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),

//               // Controls overlay
//               if (_isInitialized)
//                 AnimatedOpacity(
//                   opacity: _showControls ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 200),
//                   child: _buildControls(),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControls() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0x88000000), Colors.transparent, Color(0xCC000000)],
//           stops: [0.0, 0.4, 1.0],
//         ),
//       ),
//       child: Column(
//         children: [
//           // Top bar
//           SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: Icon(
//                       _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                     onPressed: _toggleFullscreen,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const Spacer(),

//           // Center playback controls
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _ControlButton(icon: Icons.replay_10, onTap: _skipBackward),
//               const SizedBox(width: 24),
//               GestureDetector(
//                 onTap: _togglePlayPause,
//                 child: Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withAlphaOpacity(0.15),
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: Icon(
//                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 32,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 24),
//               _ControlButton(icon: Icons.forward_10, onTap: _skipForward),
//             ],
//           ),

//           const Spacer(),

//           // Bottom seek bar
//           SafeArea(
//             top: false,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//               child: Column(
//                 children: [
//                   SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       trackHeight: 2,
//                       thumbShape: const RoundSliderThumbShape(
//                         enabledThumbRadius: 6,
//                       ),
//                       overlayShape: const RoundSliderOverlayShape(
//                         overlayRadius: 14,
//                       ),
//                       activeTrackColor: Colors.white,
//                       inactiveTrackColor: Colors.white30,
//                       thumbColor: Colors.white,
//                       overlayColor: Colors.white24,
//                     ),
//                     child: Slider(
//                       value: _position.inMilliseconds.toDouble().clamp(
//                         0,
//                         _duration.inMilliseconds.toDouble(),
//                       ),
//                       min: 0,
//                       max: _duration.inMilliseconds.toDouble(),
//                       onChanged: _onSliderChanged,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           _formatDuration(_position),
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                             fontFeatures: [FontFeature.tabularFigures()],
//                           ),
//                         ),
//                         Text(
//                           _formatDuration(_duration),
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                             fontFeatures: [FontFeature.tabularFigures()],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoInfo() {
//     final fileName = path.basename(widget.videoPath);
//     return Expanded(
//       child: Container(
//         color: const Color(0xFF0F0F0F),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.title ?? fileName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.access_time,
//                     color: Colors.white54,
//                     size: 14,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     _formatDuration(_duration),
//                     style: const TextStyle(color: Colors.white54, fontSize: 13),
//                   ),
//                   const SizedBox(width: 16),
//                   const Icon(
//                     Icons.folder_outlined,
//                     color: Colors.white54,
//                     size: 14,
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       path.dirname(widget.videoPath),
//                       style: const TextStyle(
//                         color: Colors.white54,
//                         fontSize: 13,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               // Thumbnail preview strip
//               if (_thumbnailPath != null) ...[
//                 const Text(
//                   'Thumbnail',
//                   style: TextStyle(
//                     color: Colors.white38,
//                     fontSize: 11,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.file(
//                     File(_thumbnailPath!),
//                     height: 90,
//                     width: 160,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ControlButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;

//   const _ControlButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Icon(icon, color: Colors.white, size: 36),
//     );
//   }
// }
