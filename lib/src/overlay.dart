import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import 'overlay_clipper.dart';
import 'scanner_border_painter.dart';
import 'scanner_line_painter.dart';

const _kBorderRadius = 16.0;

enum ScannerAnimation { center, fullWidth, none }

enum ScannerOverlayBackground { center, none }

enum ScannerBorder { center, none }

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
  final Color? successColor;
  final Color? errorColor;
  final bool animateOnSuccess;
  final bool animateOnError;

  const ScannerOverlayConfig({
    this.animationColor = CupertinoColors.systemGreen,
    this.borderColor = CupertinoColors.systemGrey,
    this.backgroundBlurColor = CupertinoColors.systemFill,
    this.borderRadius = _kBorderRadius,
    this.cornerRadius = _kBorderRadius,
    this.scannerAnimation = ScannerAnimation.center,
    this.scannerOverlayBackground = ScannerOverlayBackground.center,
    this.scannerBorder = ScannerBorder.center,
    this.curve,
    this.background,
    this.lineThickness = 4,
    this.animation,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.successColor = CupertinoColors.systemGreen,
    this.errorColor = CupertinoColors.systemRed,
    this.animateOnSuccess = true,
    this.animateOnError = true,
  });

  bool get isScannerAnimationCenter =>
      scannerAnimation == ScannerAnimation.center;

  bool get isScannerAnimationFullWidth =>
      scannerAnimation == ScannerAnimation.fullWidth;

  bool get isScannerOverlayBackgroundCenter =>
      scannerOverlayBackground == ScannerOverlayBackground.center;

  bool get isScannerBorderCenter => scannerBorder == ScannerBorder.center;

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
  }) =>
      ScannerOverlayConfig(
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
      );
}

class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    super.key,
    this.config = const ScannerOverlayConfig(),
    this.isSuccess,
  });

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    _animation = config.animation ??
        Tween<double>(
                begin: 0,
                end: config.scannerAnimation == ScannerAnimation.center
                    ? 1
                    : screenHeight - 100)
            .animate(
          CurvedAnimation(
            parent: _controller,
            curve: config.curve ?? Curves.linear,
          ),
        );
    return Stack(
      children: [
        if (config.isScannerOverlayBackgroundCenter)
          Positioned.fill(
            child: ClipPath(
              clipper: OverlayClipper(
                borderRadius: config.borderRadius,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: config.background ??
                    Container(color: _buildBackgroundBlurColor()),
              ),
            ),
          ),
        if (config.isScannerBorderCenter)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerCornerPainter(
                cornerRadius: config.cornerRadius,
                borderColor: _buildBorderColor(),
              ),
            ),
          ),
        if (config.isScannerAnimationFullWidth)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: _animation.value,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final isForward =
                        _controller.status == AnimationStatus.forward;
                    return LinearGradient(
                      begin: isForward
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      end: isForward
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      colors: [
                        config.animationColor.withValues(alpha: 0.0),
                        config.animationColor,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    width: screenWidth,
                    height: config.lineThickness,
                    color: config.animationColor,
                  ),
                ),
              );
            },
          )
        else if (config.isScannerAnimationCenter)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanningLinePainter(
                    animationValue: _animation.value,
                    lineThickness: config.lineThickness,
                    animationColor: config.animationColor,
                  ),
                );
              },
            ),
          )
      ],
    );
  }

  Color _buildBorderColor() {
    final color = widget.config.borderColor;
    final successColor = widget.config.successColor;
    final errorColor = widget.config.errorColor;
    final animateOnSuccess = widget.config.animateOnSuccess;
    final animateOnError = widget.config.animateOnError;

    if (animateOnSuccess && (widget.isSuccess ?? false)) {
      return successColor ?? color;
    }
    if (animateOnError &&
        ((widget.isSuccess != null) && !(widget.isSuccess ?? false))) {
      return errorColor ?? color;
    }
    return color;
  }

  Color _buildBackgroundBlurColor() {
    final color = widget.config.backgroundBlurColor;
    final successColor = widget.config.successColor?.withValues(alpha: 0.2);
    final errorColor = widget.config.errorColor?.withValues(alpha: 0.2);
    final animateOnSuccess = widget.config.animateOnSuccess;
    final animateOnError = widget.config.animateOnError;

    if (animateOnSuccess && (widget.isSuccess ?? false)) {
      return successColor ?? color;
    }
    if (animateOnError &&
        ((widget.isSuccess != null) && !(widget.isSuccess ?? false))) {
      return errorColor ?? color;
    }
    return color;
  }
}
