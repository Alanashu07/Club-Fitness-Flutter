import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/widgets/common_widgets.dart';

class ImageSlider extends StatefulWidget {
  final List<String?> images;
  final int initialIndex;
  final bool isNetwork;
  final void Function(int index) onPageChanged;

  const ImageSlider({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.isNetwork = true,
    required this.onPageChanged,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider>
    with TickerProviderStateMixin {
  late PageController _pageController;
  bool _showAppBar = true;
  List<String?> downloadedImages = [];

  void _getImages() async {
    for (final image in widget.images) {
      if (!widget.isNetwork) {
        setState(() {
          downloadedImages.add(image);
        });
      } else {
        String? imageUrl;
        imageUrl = await image?.imagePath;
        setState(() {
          downloadedImages.add(imageUrl);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _getImages();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  void _handleClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (downloadedImages.isNotEmpty)
            PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: downloadedImages.length,
              onPageChanged: widget.onPageChanged,
              builder: (_, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(downloadedImages[index] ?? '')),
                  errorBuilder: EndPoints.isProduction
                      ? null
                      : (context, error, stackTrace) =>
                            Center(child: Text(error.toString())),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  initialScale: PhotoViewComputedScale.contained,
                  onTapDown: (context, details, value) {
                    _toggleAppBar();
                  },
                );
              },
            ),
          if (_showAppBar)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _handleClose,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final bool isNetwork;
  final VoidCallback? onTap;
  final VoidCallback? onSwipeDown;
  final ValueChanged<bool>? onZooming;

  const ZoomableImage({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.onSwipeDown,
    this.onZooming,
    this.isNetwork = true,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState
    extends
        State<ZoomableImage> // with TickerProviderStateMixin
        {
  // final TransformationController _controller = TransformationController();
  // TapDownDetails? _doubleTapDetails;
  // late AnimationController _animationController;
  // Animation<Matrix4>? _animation;
  //
  // double _scale = 1.0;
  // Offset _startingFocalPoint = Offset.zero;
  // Offset _currentFocalPoint = Offset.zero;
  //
  // static const double _zoomScale = 2.5;
  //
  // void _updateZoomState() {
  //   final isZoomed = _scale > 1.01;
  //   widget.onZooming?.call(isZoomed);
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   _animationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 300),
  //   )..addListener(() {
  //       _controller.value = _animation!.value;
  //     });
  //
  //   _controller.addListener(() {
  //     final newScale = _controller.value.getMaxScaleOnAxis();
  //     if ((_scale - newScale).abs() > 0.01) {
  //       _scale = newScale;
  //       _updateZoomState();
  //     }
  //   });
  // }
  //
  // void _handleDoubleTap() {
  //   final position = _doubleTapDetails!.localPosition;
  //
  //   final zoomedIn = _scale > 1.05;
  //   late Matrix4 targetMatrix;
  //
  //   if (zoomedIn) {
  //     targetMatrix = Matrix4.identity();
  //   } else {
  //     final x = -position.dx * (_zoomScale - 1);
  //     final y = -position.dy * (_zoomScale - 1);
  //     targetMatrix = Matrix4.identity()
  //       ..translate(x, y)
  //       ..scale(_zoomScale);
  //   }
  //
  //   _animation = Matrix4Tween(
  //     begin: _controller.value,
  //     end: targetMatrix,
  //   ).animate(CurvedAnimation(
  //     parent: _animationController,
  //     curve: Curves.easeInOut,
  //   ));
  //
  //   _animationController.forward(from: 0);
  // }
  //
  // double _dragDistance = 0;

  String? _imageUrl;
  bool _failure = false;

  @override
  void initState() {
    super.initState();
    setImage();
  }

  void setImage() async {
    if (!widget.isNetwork) {
      _imageUrl = widget.imageUrl;
    } else {
      _imageUrl = await widget.imageUrl.imagePath;
    }
    setState(() {
      _failure = _imageUrl == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_imageUrl == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PhotoView(
      imageProvider: _failure
          ? NetworkImage(widget.imageUrl.toUrl)
          : FileImage(File(_imageUrl!)),
    );
    // return GestureDetector(
    //   onTap: widget.onTap,
    //   onDoubleTapDown: (details) => _doubleTapDetails = details,
    //   onDoubleTap: _handleDoubleTap,
    //   onVerticalDragStart: (details) {
    //     _startingFocalPoint = details.localPosition;
    //   },
    //   onVerticalDragUpdate: (details) {
    //     _currentFocalPoint = details.localPosition;
    //     _dragDistance = _currentFocalPoint.dy - _startingFocalPoint.dy;
    //   },
    //   onVerticalDragEnd: (details) {
    //     if (_dragDistance > 120 && _scale <= 1.05) {
    //       widget.onSwipeDown?.call();
    //     }
    //   },
    //   child: InteractiveViewer(
    //     transformationController: _controller,
    //     panEnabled: true,
    //     scaleEnabled: true,
    //     minScale: 1.0,
    //     maxScale: 4.0,
    //     clipBehavior: Clip.none,
    //     child: widget.isNetwork
    //         ? CustomCachedImage(
    //             widget.imageUrl,
    //             fit: BoxFit.contain,
    //             placeholder: const Center(
    //                 child: CircularProgressIndicator(
    //               color: Colors.white,
    //             )),
    //             errorWidget: ({error, errorTitle, url}) => Container(),
    //             errorLetter: '',
    //           )
    //         : Image.file(
    //             File(widget.imageUrl),
    //             fit: BoxFit.contain,
    //           ),
    //   ),
    // );
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   _animationController.dispose();
  //   super.dispose();
  // }
}
