// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../util/images.dart';

class CachedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final double borderRadius;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget placeholder() {
      return Image.asset(
        Images.placeholderImage,
        height: height,
        width: width,
        fit: fit,
      );
    }

    if (imageUrl.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: placeholder(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => placeholder(),
        errorWidget: (context, url, error) => placeholder(),
      ),
    );
  }
}
