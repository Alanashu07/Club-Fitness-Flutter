import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/image_cache/presentation/widgets/custom_cached_image.dart';
import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final Color primary, secondary;
  final double size;
  final double radius;
  final double fontSize;

  const MemberAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    required this.primary,
    required this.secondary,
    required this.size,
    required this.radius,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: secondary,
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
      ),
    );
    final hasImage = imageUrl?.orNull() != null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CustomCachedImage(
              imageUrl!, // prefix with your base URL here if the API returns a relative path
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
              placeholder: fallback,
            )
          : fallback,
    );
  }
}
