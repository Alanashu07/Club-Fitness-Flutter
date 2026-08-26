import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/exceptions/status_codes.dart';
import 'package:club_fitness/core/services/image_cache_manager.dart';
import 'package:club_fitness/features/image_cache/presentation/cubit/cache_image_cubit.dart';

import '../../../../widgets/common_widgets.dart';

class CustomCachedImage extends StatefulWidget {
  final String? url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final Widget? placeholder;
  final String? errorLetter;
  final int? id;
  final bool isNetwork;

  final Widget Function(String? errorTitle, String? error, String? url)?
  errorBuilder;

  const CustomCachedImage(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorBuilder,
    this.errorLetter,
    this.id,
    this.isNetwork = true,
  });

  @override
  State<CustomCachedImage> createState() => _CustomCachedImageState();
}

class _CustomCachedImageState extends State<CustomCachedImage> {
  File? _imageFile;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant CustomCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.url != oldWidget.url) {
      _reset();
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      _validateUrl();

      if (!widget.isNetwork) {
        return _setImage(File(widget.url!));
      }

      final cachedImage = await context
          .read<CacheImageCubit>()
          .getOrDownloadImage(imageUrl);

      if (cachedImage != null && cachedImage.filePath.isNotEmpty) {
        return _setImage(File(cachedImage.filePath));
      }

      final file = await _cacheManager.getSingleFile(imageUrl);

      _setImage(file);
    } catch (e) {
      _setFailure(Failure.fromException(e));
    }
  }

  void _validateUrl() {
    if (widget.url == null || widget.url!.isEmpty) {
      throw StatusCodes.errorFromStatusCode(StatusCodes.notFound);
    }
  }

  void _setImage(File file) {
    if (!mounted) return;

    setState(() {
      _imageFile = file;
      _failure = null;
    });
  }

  void _setFailure(Failure failure) {
    if (!mounted) return;

    setState(() {
      _failure = failure;
    });
  }

  void _reset() {
    _imageFile = null;
    _failure = null;
  }

  bool get _hasLetterFallback => widget.errorLetter?.trim().isNotEmpty ?? false;

  bool get _hasFailure => _failure != null;

  bool get _isLoading => _imageFile == null && !_hasFailure;

  bool _isValidImage(File file) {
    final path = file.path.toLowerCase();

    const invalidExtensions = ['.mp4', '.webm', '.mov', '.html'];

    return !invalidExtensions.any(path.endsWith);
  }

  Widget _buildFailureWidget() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(
        _failure?.title,
        _failure?.message,
        widget.url,
      );
    }

    if (_hasLetterFallback) {
      return LetterWidget(letter: widget.errorLetter!, index: widget.id ?? 0);
    }

    return const Center(child: Icon(Icons.error));
  }

  Widget _buildInvalidImageWidget() {
    return widget.errorBuilder?.call(
          'Invalid data',
          'Current image data is not a valid image',
          widget.url,
        ) ??
        const Center(child: Icon(Icons.error));
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        LoadingWidget(height: widget.height, width: widget.width);
  }

  Widget _buildLetterFallback() {
    return LetterWidget(
      letter: widget.errorLetter ?? '',
      index: widget.id ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) {
      return _hasLetterFallback
          ? _buildLetterFallback()
          : const SizedBox.shrink();
    }

    if (_hasFailure) {
      return _buildFailureWidget();
    }

    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (!_isValidImage(_imageFile!)) {
      return _buildInvalidImageWidget();
    }

    return Image.file(
      _imageFile!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      alignment: widget.alignment,
    );
  }

  ImageCacheManager get _cacheManager {
    return ImageCacheManager(
      maxAge: const Duration(days: 30),
      maxObjects: 3000000,
    );
  }

  String get imageUrl {
    final url = widget.url!;

    if (url.startsWith('http')) {
      return url;
    }

    if (url.contains('media')) {
      return '${EndPoints.baseUrl}/$url';
    }

    return '${EndPoints.baseUrl}/media/$url';
  }
}
