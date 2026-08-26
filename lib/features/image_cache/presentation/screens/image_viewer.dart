import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:club_fitness/config/theme/theme.dart';
import '../widgets/image_slider.dart';

class ImageViewer extends StatefulWidget {
  final String? image;
  final List<String?>? images;
  final int initialIndex;
  final String? title;
  final String? caption;
  final List<String>? captions;
  final List<String>? tags;
  final bool isNetwork;

  const ImageViewer({
    super.key,
    this.image,
    this.images,
    this.initialIndex = 0,
    this.title,
    this.caption,
    this.captions,
    this.tags,
    this.isNetwork = true,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _showInfo = true;
  late AnimationController _infoCtrl;
  late Animation<double> _infoFade;
  late Animation<Offset> _infoSlide;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _infoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _infoFade = CurvedAnimation(parent: _infoCtrl, curve: Curves.easeOut);
    _infoSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _infoCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _infoCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _toggleInfo() {
    setState(() => _showInfo = !_showInfo);
    if (_showInfo) {
      _infoCtrl.forward();
    } else {
      _infoCtrl.reverse();
    }
  }

  String? get _currentCaption {
    if (widget.image != null) return widget.caption;
    if (widget.captions != null && _currentIndex < widget.captions!.length) {
      return widget.captions![_currentIndex];
    }
    return null;
  }

  List<String> get _allImages =>
      widget.images?.whereType<String>().toList() ?? [];

  @override
  Widget build(BuildContext context) {
    if (widget.image != null && widget.images != null) {
      return _errorScreen(
        'Either give one image or give List of images, not both!!',
      );
    }
    if (widget.image == null && widget.images == null) {
      return _errorScreen(
        'You have to give either one image or List of images',
      );
    }

    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isSingle = widget.image != null;
    final total = isSingle ? 1 : _allImages.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleInfo,
        child: Stack(
          children: [
            // ── Image / Slider ─────────────────────────────
            Positioned.fill(
              child: isSingle
                  ? ZoomableImage(
                      imageUrl: widget.image!,
                      isNetwork: widget.isNetwork,
                      onSwipeDown: () => context.pop(),
                    )
                  : ImageSlider(
                      images: widget.images!,
                      initialIndex: widget.initialIndex,
                      isNetwork: widget.isNetwork,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                    ),
            ),

            // ── Top bar ────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _infoFade,
                child: Container(
                  padding: EdgeInsets.only(
                    top: topPad + 8,
                    left: 8,
                    right: 16,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAOpacity(0.72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Title
                      Expanded(
                        child: widget.title != null
                            ? Text(
                                widget.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Counter pill
                      if (total > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / $total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom info panel ──────────────────────────
            if (_currentCaption != null ||
                (widget.tags != null && widget.tags!.isNotEmpty))
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FadeTransition(
                  opacity: _infoFade,
                  child: SlideTransition(
                    position: _infoSlide,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 20,
                        bottom: bottomPad + 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withAOpacity(0.82),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Caption
                          if (_currentCaption != null &&
                              _currentCaption!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [AppTheme.primary, AppTheme.secondary],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _currentCaption!,
                                    style: TextStyle(
                                      color: Colors.white.withAOpacity(
                                        0.92,
                                      ),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Tags
                          if (widget.tags != null &&
                              widget.tags!.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: widget.tags!
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withAOpacity(
                                          0.22,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.primary
                                              .withAOpacity(0.45),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.tag_rounded,
                                            size: 10,
                                            color: AppTheme.secondary,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            tag,
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withAOpacity(0.88),
                                              fontSize: 10,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],

                          // Dot indicators
                          if (total > 1) ...[
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                total > 8 ? 0 : total,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: i == _currentIndex ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == _currentIndex
                                        ? AppTheme.primary
                                        : Colors.white.withAOpacity(0.35),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Tap-to-toggle hint (first 2 seconds) ──────
          ],
        ),
      ),
    );
  }

  Widget _errorScreen(String message) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.broken_image_rounded,
                  color: AppTheme.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
