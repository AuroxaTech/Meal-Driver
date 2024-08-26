import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    required this.imageUrl,
    this.height = Vx.dp40,
    this.width,
    this.boxFit,
    super.key,
  });

  final String imageUrl;
  final double height;
  final double? width;
  final BoxFit? boxFit;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: boxFit ?? BoxFit.cover,
      progressIndicatorBuilder: (context, imageURL, progress) =>
          const BusyIndicator().centered(),
    ).h(height).w(width ?? context.percentWidth);
  }
}
