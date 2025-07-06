// lib/src/overlay.dart
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import 'overlay_clipper.dart';
import 'scanner_border_painter.dart';
import 'scanner_line_painter.dart';

const _kBorderRadius = 24.0;

enum ScannerAnimation { center, fullWidth, none }

enum ScannerOverlayBackground { blur, none }

enum ScannerBorder { corner, full, none }

class ScannerOverlayConfig {
  final Color animationColor;
  final Color borderColor;
  final Color backgroundBlurColor;
  final double borderRadius;
  final double cornerRadius;
  final ScannerAnimation scannerAnimation;
  final ScannerOverlayBackground scannerOverlayBackground;
  final ScannerBorder scannerBorder;
  final Cubic? curve;
  final Widget? background;
  final double lineThickness;
  final Animation<double>? animation;
  final Duration animationDuration;
  final Color successColor;
  final Color errorColor;
  final bool animateOnSuccess;
  final bool animateOnError;
  // NEW: Added corner length to allow customization of the corner painter.
  final double cornerLength;

  const ScannerOverlayConfig({
    this.animationColor = CupertinoColors.systemGreen,
    this.borderColor = CupertinoColors.systemGrey,
    this.backgroundBlurColor = CupertinoColors.systemFill,
    this.borderRadius = _kBorderRadius,
    this.cornerRadius = _kBorderRadius,
    this.scannerAnimation = ScannerAnimation.center,
    this.scannerOverlayBackground = ScannerOverlayBackground.blur,
    this.scannerBorder = ScannerBorder.corner,
    this.curve,
    this.background,
    this.lineThickness = 4,
    this.animation,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.successColor = CupertinoColors.systemGreen,
    this.errorColor = CupertinoColors.systemRed,
    this.animateOnSuccess = true,
    this.animateOnError = true,
    this.cornerLength = 60.0,
  });

  ScannerOverlayConfig copyWith({
    Color? animationColor,
    Color? borderColor,
    Color? backgroundBlurColor,
    double? borderRadius,
    double? cornerRadius,
    ScannerAnimation? scannerAnimation,
    ScannerOverlayBackground? scannerOverlayBackground,
    ScannerBorder? scannerBorder,
    Cubic? curve,
    Widget? background,
    double? lineThickness,
    Animation<double>? animation,
    Duration? animationDuration,
    Color? successColor,
    Color? errorColor,
    bool? animateOnSuccess,
    bool? animateOnError,
    double? cornerLength,
  }) {
    return ScannerOverlayConfig(
      animationColor: animationColor ?? this.animationColor,
      borderColor: borderColor ?? this.borderColor,
      backgroundBlurColor: backgroundBlurColor ?? this.backgroundBlurColor,
      borderRadius: borderRadius ?? this.borderRadius,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      scannerAnimation: scannerAnimation ?? this.scannerAnimation,
      scannerOverlayBackground:
          scannerOverlayBackground ?? this.scannerOverlayBackground,
      scannerBorder: scannerBorder ?? this.scannerBorder,
      curve: curve ?? this.curve,
      background: background ?? this.background,
      lineThickness: lineThickness ?? this.lineThickness,
      animation: animation ?? this.animation,
      animationDuration: animationDuration ?? this.animationDuration,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      animateOnSuccess: animateOnSuccess ?? this.animateOnSuccess,
      animateOnError: animateOnError ?? this.animateOnError,
      cornerLength: cornerLength ?? this.cornerLength,
    );
  }
}

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    super.key,
    required this.scanWindow,
    this.config = const ScannerOverlayConfig(),
    this.isSuccess,
  });

  final Rect scanWindow;
  final ScannerOverlayConfig config;
  final bool? isSuccess;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.config.curve ?? Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(Color defaultColor, Color successColor, Color errorColor) {
    if (widget.config.animateOnSuccess && (widget.isSuccess ?? false)) {
      return successColor;
    }
    if (widget.config.animateOnError &&
        (widget.isSuccess != null && !widget.isSuccess!)) {
      return errorColor;
    }
    return defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final screenSize = MediaQuery.of(context).size;
    final borderColor = _getColor(
      config.borderColor,
      config.successColor,
      config.errorColor,
    );
    final backgroundColor = _getColor(
      config.backgroundBlurColor,
      config.successColor.withValues(alpha: 0.2),
      config.errorColor.withValues(alpha: 0.2),
    );

    return Stack(
      children: [
        if (config.scannerOverlayBackground == ScannerOverlayBackground.blur)
          Positioned.fill(
            child: ClipPath(
              clipper: OverlayClipper(
                scanWindow: widget.scanWindow,
                borderRadius: config.borderRadius,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: config.background ?? Container(color: backgroundColor),
              ),
            ),
          ),
        if (config.scannerBorder != ScannerBorder.none)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerCornerPainter(
                scanWindow: widget.scanWindow,
                borderRadius: config.borderRadius,
                cornerRadius: config.cornerRadius,
                borderColor: borderColor,
                borderType: config.scannerBorder,
                cornerLength: config.cornerLength,
              ),
            ),
          ),
        // RENDER THE CORRECT ANIMATION
        if (config.scannerAnimation == ScannerAnimation.center)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanningLinePainter(
                    animationValue: _animation.value,
                    scanWindow: widget.scanWindow,
                    lineThickness: config.lineThickness,
                    animationColor: config.animationColor,
                    borderRadius: config.borderRadius,
                  ),
                );
              },
            ),
          ),
        // CORRECTED: This block now correctly renders the full-width animation.
        if (config.scannerAnimation == ScannerAnimation.fullWidth)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Calculate the top position based on the screen height and animation value (0.0 to 1.0)
              final topPosition = _animation.value * screenSize.height;

              return Positioned(
                top: topPosition,
                left: 0,
                right: 0,
                child: Container(
                  height: 120, // A more visible height for the glowing effect
                  width: screenSize.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        config.animationColor.withValues(alpha: 0.0),
                        config.animationColor.withValues(alpha: 0.4),
                        config.animationColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.1, 0.5, 0.9],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
