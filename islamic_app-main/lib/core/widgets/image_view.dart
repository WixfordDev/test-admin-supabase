import 'dart:io';

import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/ink_well_view.dart';
import 'package:deenhub/core/widgets/svg_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  ///[imagePath] is required parameter for showing image
  final dynamic imagePath;
  final bool isFile;

  final double? height;
  final double? width;
  final Color? color;
  final Color? backgroundColor;
  final BoxShape? backgroundShape;
  final List<BoxShadow>? boxShadow;
  final Clip? clipBehavior;
  final BoxFit? fit;
  final String placeHolder;
  final BorderRadiusDirectional? radius;
  final BorderRadiusDirectional? backgroundRadius;
  final EdgeInsetsDirectional? margin;
  final EdgeInsetsDirectional? padding;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final void Function(TapDownDetails)? onTapDown;

  ///a [ImageView] it can be used for showing any type of images
  /// it will shows the placeholder image if image is not found on network image
  const ImageView({
    super.key,
    required this.imagePath,
    this.isFile = false,
    this.height,
    this.width,
    this.color,
    this.backgroundColor,
    this.backgroundShape,
    this.boxShadow,
    this.clipBehavior,
    this.fit,
    this.placeHolder = Assets.imagesIcImageNotFound,
    this.radius,
    this.backgroundRadius,
    this.margin,
    this.padding,
    this.border,
    this.onTap,
    this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsetsDirectional.zero,
      child: (onTap != null)
          ? InkWellView(
              shapeBorder: const CircleBorder(),
              onTap: onTap,
              onTapDown: onTapDown,
              child: _buildCircleImage(),
            )
          : _buildCircleImage(),
    );
  }

  /// build the image with border radius
  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadiusDirectional.zero,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  /// build the image with border and border radius style
  Widget _buildImageWithBorder() {
    if (padding != null ||
        clipBehavior != null ||
        border != null ||
        backgroundRadius != null ||
        backgroundColor != null ||
        backgroundShape != null ||
        boxShadow != null) {
      return Container(
        padding: padding ?? EdgeInsetsDirectional.zero,
        clipBehavior: clipBehavior ?? Clip.none,
        decoration: BoxDecoration(
          border: border,
          borderRadius: backgroundRadius,
          color: backgroundColor,
          shape: backgroundShape ?? BoxShape.rectangle,
          boxShadow: boxShadow,
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    switch (getImageType()) {
      case ImageType.iconData:
        return Icon(imagePath as IconData, size: height, color: color);

      case ImageType.svg:
        return SvgImage(
          asset: imagePath as String,
          height: height,
          width: width,
          color: color,
        );

      case ImageType.file:
        return Image.file(
          File(imagePath as String),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (context, error, stackTrace) => _buildErrorView(context),
        );

      case ImageType.network:
        return CachedNetworkImage(
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          imageUrl: imagePath as String,
          color: color,
          placeholder: (context, url) => LinearProgressIndicator(
            color: Colors.grey.shade200,
            backgroundColor: Colors.grey.shade100,
          ).box(width: 30, height: 30),
          errorWidget: (context, url, error) => _buildErrorView(context),
        );

      case ImageType.png:
      default:
        return Image.asset(
          imagePath as String,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (context, error, stackTrace) => _buildErrorView(context),
        );
    }
  }

  Widget _buildErrorView(BuildContext context) {
    return SvgImage(
      asset: placeHolder,
      height: height,
      width: width,
      color: context.errorColor,
    );
  }

  ImageType getImageType() {
    if (imagePath is IconData) {
      return ImageType.iconData;
    } else {
      final path = (imagePath as String);

      if (isFile || path.startsWith('file://')) {
        return ImageType.file;
      } else if (path.startsWith('http') || path.startsWith('https')) {
        return ImageType.network;
      } else if (path.endsWith('.svg')) {
        return ImageType.svg;
      } else {
        return ImageType.png;
      }
    }
  }
}

enum ImageType { iconData, svg, png, network, file, unknown }
