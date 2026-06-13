import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PremiumImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;

  const PremiumImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 80.0,
    this.height = 80.0,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(
      Icons.storefront_outlined,
      color: Colors.grey[400],
      size: width * 0.4,
    );

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildPlaceholder(fallbackIcon);
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(fallbackIcon),
      ),
    );
  }

  Widget _buildPlaceholder(Widget fallback) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(12)),
      ),
      child: Center(child: fallback),
    );
  }
}
