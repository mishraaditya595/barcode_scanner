import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:universal_platform/universal_platform.dart';

import 'error_builder.dart';
import 'gallery_button.dart';
import 'overlay.dart';

/// Barcode scanner widget
class AiBarcodeScanner extends StatefulWidget {
  /// Fit to screen
  final BoxFit fit;

  /// Barcode controller (optional)
  final MobileScannerController? controller;

  /// You can use your own custom overlay builder
  /// to build your own overlay
  /// This will override the default custom overlay
  final Widget? Function(BuildContext, bool?, MobileScannerController)?
      customOverlayBuilder;

  /// The function that builds an error widget when the scanner
  /// could not be started.
  ///
  /// If this is null, defaults to a black [ColoredBox]
  /// with a centered white [Icons.error] icon.
  final Widget Function(BuildContext, MobileScannerException)? errorBuilder;

  /// The function that builds a placeholder widget when the scanner
  /// is not yet displaying its camera preview.
  ///
  /// If this is null, a black [ColoredBox] is used as placeholder.
  final Widget Function(BuildContext)? placeholderBuilder;

  /// Called when this object is removed from the tree permanently.
  final void Function()? onDispose;

  /// AppBar widget
  /// you can use this to add appBar to the scanner screen
  final PreferredSizeWidget? Function(
    BuildContext context,
    MobileScannerController controller,
  )? appBarBuilder;

  /// The builder for the bottom sheet.
  /// This is displayed below the camera preview.
  final Widget? Function(
    BuildContext context,
    MobileScannerController controller,
  )? bottomSheetBuilder;

  /// The builder for the bottom navigation bar.
  final Widget? Function(
    BuildContext context,
    MobileScannerController controller,
  )? bottomNavigationBarBuilder;

  /// The builder for the overlay above the camera preview.
  final LayoutWidgetBuilder? overlayBuilder;

  /// The scan window rectangle for the barcode scanner.
  final Rect? scanWindow;

  /// The threshold for updates to the [scanWindow].
  final double scanWindowUpdateThreshold;

  /// Validator function to check if barcode is valid or not
  final bool Function(BarcodeCapture)? validator;

  final void Function(String?)? onImagePick;

  /// The function that is called when a barcode is detected
  final void Function(BarcodeCapture)? onDetect;

  /// Hide gallery button (default: false)
  /// This will hide the gallery button at the bottom of the screen
  final bool hideGalleryButton;

  /// Hide gallery icon (default: false)
  /// This will hide the gallery icon in the app bar
  final bool hideGalleryIcon;

  /// Extend body behind app bar (default: true)
  final bool extendBodyBehindAppBar;

  /// Upload from gallery button alignment
  final AlignmentGeometry? galleryButtonAlignment;

  /// actions for the app bar (optional)
  /// Camera switch and torch toggle buttons are added by default
  /// You can add more actions to the app bar using this parameter
  final List<Widget>? actions;

  /// Lock orientation to portrait (default: true)
  final bool setPortraitOrientation;

  final ScannerOverlayConfig overlayConfig;

  const AiBarcodeScanner({
    super.key,
    this.fit = BoxFit.cover,
    this.controller,
    this.scanWindowUpdateThreshold = 0.0,
    this.customOverlayBuilder,
    this.errorBuilder,
    this.placeholderBuilder,
    this.onDispose,
    this.scanWindow,
    this.appBarBuilder,
    this.overlayBuilder,
    this.onDetect,
    this.validator,
    this.onImagePick,
    this.hideGalleryButton = false,
    this.hideGalleryIcon = true,
    this.bottomSheetBuilder,
    this.bottomNavigationBarBuilder,
    this.extendBodyBehindAppBar = true,
    this.galleryButtonAlignment,
    this.actions,
    this.setPortraitOrientation = true,
    this.overlayConfig = const ScannerOverlayConfig(),
  });

  @override
  State<AiBarcodeScanner> createState() => _AiBarcodeScannerState();
}

class _AiBarcodeScannerState extends State<AiBarcodeScanner> {
  final ValueNotifier<bool?> _isSuccess = ValueNotifier<bool?>(null);
  late MobileScannerController controller;
  double _currentZoom = 1.0;
  double _startZoom = 1.0;

  @override
  void initState() {
    if (widget.setPortraitOrientation) {
      // Set to portrait only
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    controller = widget.controller ?? MobileScannerController();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (UniversalPlatform.value) {
      case UniversalPlatformType.Windows:
      case UniversalPlatformType.Linux:
      case UniversalPlatformType.Fuchsia:
        return Scaffold(
          appBar: widget.appBarBuilder?.call(context, controller),
          body: Center(
            child: SelectableText(
              'This platform is not supported, for more information, please visit https://pub.dev/packages/mobile_scanner#platform-support',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        );
      default:
        return Scaffold(
          appBar: widget.appBarBuilder?.call(context, controller) ??
              CupertinoNavigationBar(
                border: Border.all(color: Colors.transparent),
                backgroundColor: CupertinoColors.systemFill,
                trailing: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cameraswitch_rounded),
                      color: CupertinoColors.systemGrey6,
                      onPressed: () => controller.switchCamera(),
                    ),
                    IconButton(
                      icon: controller.value.torchState == TorchState.on
                          ? const Icon(Icons.flashlight_off_rounded)
                          : const Icon(Icons.flashlight_on_rounded),
                      color: CupertinoColors.systemGrey6,
                      onPressed: () {
                        controller.toggleTorch();
                        setState(() {});
                      },
                    ),
                    if (!widget.hideGalleryIcon)
                      GalleryButton.icon(
                        onImagePick: widget.onImagePick,
                        onDetect: widget.onDetect,
                        validator: widget.validator,
                        controller: controller,
                        isSuccess: _isSuccess,
                      ),
                    ...?widget.actions,
                  ],
                ),
              ),
          extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
          bottomSheet: widget.bottomSheetBuilder?.call(context, controller),
          bottomNavigationBar: widget.bottomNavigationBarBuilder?.call(
            context,
            controller,
          ),
          body: GestureDetector(
            onScaleStart: (details) {
              _startZoom = _currentZoom;
            },
            onScaleUpdate: (details) {
              double newZoom = (_startZoom * details.scale).clamp(1.0, 5.0);
              if (newZoom != _currentZoom) {
                setState(() => _currentZoom = newZoom);
                controller.setZoomScale(_currentZoom);
              }
            },
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: onDetect,
                  controller: controller,
                  fit: widget.fit,
                  errorBuilder:
                      widget.errorBuilder ?? (_, __) => const ErrorBuilder(),
                  placeholderBuilder: widget.placeholderBuilder,
                  scanWindow: widget.scanWindow,
                  key: widget.key,
                  overlayBuilder: widget.overlayBuilder,
                  scanWindowUpdateThreshold: widget.scanWindowUpdateThreshold,
                ),
                ValueListenableBuilder<bool?>(
                  valueListenable: _isSuccess,
                  builder: (context, isSuccess, __) {
                    return widget.customOverlayBuilder
                            ?.call(context, isSuccess, controller) ??
                        ScannerOverlay(
                          config: widget.overlayConfig,
                          isSuccess: isSuccess,
                        );
                  },
                ),
                if (!widget.hideGalleryButton)
                  Align(
                    alignment: widget.galleryButtonAlignment ??
                        Alignment.lerp(
                          Alignment.bottomCenter,
                          Alignment.center,
                          0.40,
                        )!,
                    child: GalleryButton(
                      onImagePick: widget.onImagePick,
                      onDetect: widget.onDetect,
                      validator: widget.validator,
                      controller: controller,
                      isSuccess: _isSuccess,
                    ),
                  ),
              ],
            ),
          ),
        );
    }
  }

  void onDetect(BarcodeCapture barcodes) {
    try {
      widget.onDetect?.call(barcodes);
      if (widget.validator != null) {
        final isValid = widget.validator!(barcodes);
        _isSuccess.value = isValid;
        if (!isValid) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      _isSuccess.value = false;
    }
  }
}
