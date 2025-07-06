import 'package:flutter/material.dart';

class OverlayClipper extends CustomClipper<Path> {
  OverlayClipper({this.borderRadius});
  final double? borderRadius;
  @override
  Path getClip(Size size) {
    final path = Path();

    // Rectangle with rounded corners for the transparent area
    final overlayRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.4,
    );
    final roundedRect = RRect.fromRectAndRadius(
      overlayRect,
      Radius.circular(borderRadius ?? 16),
    );

    // Full screen with cutout
    path
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(roundedRect)
      ..fillType = PathFillType.evenOdd; // Cutout effect

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
