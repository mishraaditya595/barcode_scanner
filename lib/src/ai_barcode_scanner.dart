import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'draggable_sheet.dart';
import 'error_builder.dart';
import 'gallery_button.dart';
import 'overlay.dart';

/// Barcode scanner widget
class AiBarcodeScanner extends StatefulWidget {
  final BoxFit fit;
  final MobileScannerController? controller;
  final Widget? Function(BuildContext, bool?, MobileScannerController)? customOverlayBuilder;
  final Color? borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double? cutOutWidth;
  final double? cutOutHeight;
  final double cutOutBottomOffset;
  final double cutOutSize;
  final bool showError;
  final Color errorColor;
  final bool showSuccess;
  final Color successColor;
  final Widget Function(BuildContext, MobileScannerException, Widget?)? errorBuilder;
  final Widget Function(BuildContext, Widget?)? placeholderBuilder;
  final void Function()? onDispose;
  final PreferredSizeWidget? Function(BuildContext context, MobileScannerController controller)? appBarBuilder;
  final Widget? Function(BuildContext context, MobileScannerController controller)? bottomSheetBuilder;
  final LayoutWidgetBuilder? overlayBuilder;
  final Rect? scanWindow;
  final void Function(BarcodeCapture)? onDetect;
  final bool Function(BarcodeCapture)? validator;
  final void Function(String?)? onImagePick;
  final double scanWindowUpdateThreshold;
  final String sheetTitle;
  final Widget sheetChild;
  final bool hideSheetDragHandler;
  final bool hideSheetTitle;
  final bool hideGalleryButton;
  final bool hideGalleryIcon;
  final bool extendBodyBehindAppBar;
  final AlignmentGeometry? galleryButtonAlignment;
  final List<Widget>? actions;
  final bool setPortraitOrientation;

  const AiBarcodeScanner({
    super.key,
    this.fit = BoxFit.cover,
    this.controller,
    this.borderColor,
    this.cutOutWidth,
    this.cutOutHeight,
    this.borderWidth = 12,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 82),
    this.borderRadius = 24,
    this.borderLength = 42,
    this.cutOutSize = 320,
    this.cutOutBottomOffset = 110,
    this.scanWindowUpdateThreshold = 0.0,
    this.customOverlayBuilder,
    this.showError = true,
    this.showSuccess = true,
    this.errorColor = Colors.red,
    this.successColor = Colors.green,
    this.errorBuilder,
    this.placeholderBuilder,
    this.onDispose,
    this.scanWindow,
    this.appBarBuilder,
    this.overlayBuilder,
    this.onDetect,
    this.validator,
    this.onImagePick,
    this.sheetTitle = 'Scan any QR code',
    this.sheetChild = const SizedBox.shrink(),
    this.hideSheetDragHandler = false,
    this.hideSheetTitle = false,
    this.hideGalleryButton = false,
    this.hideGalleryIcon = true,
    this.bottomSheetBuilder,
    this.extendBodyBehindAppBar = true,
    this.galleryButtonAlignment,
    this.actions,
    this.setPortraitOrientation = true,
  });

  @override
  State<AiBarcodeScanner> createState() => _AiBarcodeScannerState();
}

class _AiBarcodeScannerState extends State<AiBarcodeScanner> {
  final ValueNotifier<bool?> _isSuccess = ValueNotifier<bool?>(null);
  late MobileScannerController controller;
  double _cutOutBottomOffset = 0;

  @override
  void initState() {
    if (widget.setPortraitOrientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    controller = widget.controller ?? MobileScannerController();
    _cutOutBottomOffset = widget.cutOutBottomOffset;
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    widget.onDispose?.call();
    if (widget.setPortraitOrientation) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder?.call(context, controller) ??
          AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.cameraswitch_rounded),
                onPressed: () => controller.switchCamera(),
              ),
              IconButton(
                icon: controller.value.torchState == TorchState.on
                    ? const Icon(Icons.flashlight_off_rounded)
                    : const Icon(Icons.flashlight_on_rounded),
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
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      bottomSheet: widget.bottomSheetBuilder?.call(context, controller) ??
          DraggableSheet(
            title: widget.sheetTitle,
            hideDragHandler: widget.hideSheetDragHandler,
            hideTitle: widget.hideSheetTitle,
            child: widget.sheetChild,
          ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: onDetect,
            controller: controller,
            fit: widget.fit,
            errorBuilder: widget.errorBuilder ?? (_, __, ___) => const ErrorBuilder(),
            placeholderBuilder: widget.placeholderBuilder,
            scanWindow: widget.scanWindow,
            key: widget.key,
            overlayBuilder: widget.overlayBuilder,
            scanWindowUpdateThreshold: widget.scanWindowUpdateThreshold,
          ),
          ValueListenableBuilder<bool?>(
            valueListenable: _isSuccess,
            builder: (context, isSuccess, __) {
              return widget.customOverlayBuilder?.call(context, isSuccess, controller) ??
                  Container(
                    decoration: ShapeDecoration(
                      shape: OverlayShape(
                        borderRadius: widget.borderRadius,
                        borderColor: ((isSuccess ?? false) && widget.showSuccess)
                            ? widget.successColor
                            : (!(isSuccess ?? true) && widget.showError)
                                ? widget.errorColor
                                : widget.borderColor ?? Colors.white,
                        borderLength: widget.borderLength,
                        borderWidth: widget.borderWidth,
                        cutOutSize: widget.cutOutSize,
                        cutOutBottomOffset: _cutOutBottomOffset,
                        cutOutWidth: widget.cutOutWidth,
                        cutOutHeight: widget.cutOutHeight,
                        overlayColor: ((isSuccess ?? false) && widget.showSuccess)
                            ? widget.successColor.withOpacity(0.4)
                            : (!(isSuccess ?? true) && widget.showError)
                                ? widget.errorColor.withOpacity(0.4)
                                : widget.overlayColor,
                      ),
                    ),
                  );
            },
          ),
          if (!widget.hideGalleryButton)
            Align(
              alignment: widget.galleryButtonAlignment ??
                  Alignment.lerp(Alignment.bottomCenter, Alignment.center, 0.75)!,
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
    );
  }

  void onDetect(BarcodeCapture barcodes) {
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
  }
}
