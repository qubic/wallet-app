import 'package:flutter/material.dart';

class ScannerOverlayClipper extends CustomClipper<Path> {
  final Rect scanWindow;
  final double cornerRadius;

  ScannerOverlayClipper(this.scanWindow, {this.cornerRadius = 12.0});

  @override
  Path getClip(Size size) {
    // Create a path for the entire screen
    Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // Full screen

      // Rounded rectangle path for the scan window
      ..addRRect(
          RRect.fromRectAndRadius(scanWindow, Radius.circular(cornerRadius)));

    // Combine to exclude the scan window from the blur
    return Path.combine(
        PathOperation.difference,
        path,
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              scanWindow, Radius.circular(cornerRadius))));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
