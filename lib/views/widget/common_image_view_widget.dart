import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gesturetalk1/constants/app_colors.dart';
import 'package:svg_flutter/svg.dart';

class CommonImageView extends StatelessWidget {
  // ignore_for_file: must_be_immutable
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  double? height;
  double? width;
  double? radius;
  final BoxFit fit;
  final String placeHolder;

  CommonImageView({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius!),
            child: SvgPicture.asset(
              svgPath!,
              height: height,
              width: width,
              fit: fit,
            ),
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: Image.file(file!, height: height, width: width, fit: fit),
        ),
      );
    } else if (url != null && url!.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: CachedNetworkImage(
            height: height,
            width: width,
            fit: fit,
            imageUrl: url!,
            placeholder:
                (context, url) => SizedBox(
                  height: 23,
                  width: 23,
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: kGreyColor,
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Image.asset(
                  placeHolder,
                  height: height,
                  width: width,
                  fit: fit,
                ),
          ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return Animate(
        effects: [FadeEffect(duration: Duration(milliseconds: 500))],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    }
    return SizedBox();
  }
}

class CommonImageViewWithoutAnimate extends StatelessWidget {
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  double? height;
  double? width;
  double? radius;
  final BoxFit fit;
  final String placeHolder;

  CommonImageViewWithoutAnimate({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: SvgPicture.asset(
            svgPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.file(file!, height: height, width: width, fit: fit),
      );
    } else if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: url!,
          placeholder:
              (context, url) => SizedBox(
                height: 23,
                width: 23,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: kGreyColor,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Image.asset(
                placeHolder,
                height: height,
                width: width,
                fit: fit,
              ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.asset(imagePath!, height: height, width: width, fit: fit),
      );
    }
    return SizedBox();
  }
}

class CommonImageViewWithBorder extends StatelessWidget {
  String? url;
  String? imagePath;
  String? svgPath;
  File? file;
  double? height;
  double? width;
  double? radius;
  final BoxFit fit;
  final String placeHolder;

  CommonImageViewWithBorder({
    super.key,
    this.url,
    this.imagePath,
    this.svgPath,
    this.file,
    this.height,
    this.width,
    this.radius = 0.0,
    this.fit = BoxFit.cover,
    this.placeHolder = 'assets/images/no_image_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius!),
          child: SvgPicture.asset(
            svgPath!,
            height: height,
            width: width,
            fit: fit,
          ),
        ),
      );
    } else if (file != null && file!.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.file(file!, height: height, width: width, fit: fit),
      );
    } else if (url != null && url!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: CachedNetworkImage(
          height: height,
          width: width,
          fit: fit,
          imageUrl: url!,
          placeholder:
              (context, url) => SizedBox(
                height: 23,
                width: 23,
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: kGreyColor,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Image.asset(
                placeHolder,
                height: height,
                width: width,
                fit: fit,
              ),
        ),
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Image.asset(imagePath!, height: height, width: width, fit: fit),
      );
    }
    return SizedBox();
  }
}
