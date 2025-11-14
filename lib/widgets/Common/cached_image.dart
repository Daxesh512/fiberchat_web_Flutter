//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final bool isRound;
  final double radius;
  final double? height;
  final double? width;

  final BoxFit fit;

  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";

  CachedImage(
    this.imageUrl, {
    this.isRound = false,
    this.radius = 0,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(isRound ? 130 : radius),
            child: Image.network(
              imageUrl!,
              fit: fit,
            )),
      );
    } catch (e) {
      // print(e);
      return Image.network(noImageAvailable, fit: BoxFit.cover);
    }
  }
}
