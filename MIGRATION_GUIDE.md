# Migration Guide

This guide will help you migrate your `ai_barcode_scanner` implementation from the older versions to the new, refactored version. The new version introduces a much cleaner, more robust, and more customizable API.

The primary change is the consolidation of numerous individual styling parameters into a single, powerful configuration object: `ScannerOverlayConfig`.

## Key Changes

1.  **Overlay Configuration**: Almost all direct overlay parameters (`borderColor`, `borderWidth`, `overlayColor`, `borderRadius`, `borderLength`, etc.) have been removed from the `AiBarcodeScanner` constructor. You now pass a single `ScannerOverlayConfig` object to the `overlayConfig` parameter.
2.  **Draggable Sheet Removed**: The built-in `DraggableSheet` has been removed in favor of the more flexible `bottomSheetBuilder`. This allows you to use any widget (including `DraggableScrollableSheet`) as a bottom sheet.
3.  **Gallery Button**: The `hideGalleryButton` and `hideGalleryIcon` parameters have been replaced by a single `galleryButtonType` enum (`GalleryButtonType.filled` or `GalleryButtonType.icon`). To hide the gallery button completely, don't implement the `onImagePick` callback (though this is not a direct feature).
4.  **Pinch-to-Zoom**: This feature is now enabled by default and does not require a parameter.
5.  **Transient Feedback Color**: A new parameter `colorTransitionDuration` controls how long the success/error colors are displayed.

---

## Migration Steps

### 1. Update Overlay Parameters

The biggest change is how you style the overlay.

**Old Code:**
```dart
AiBarcodeScanner(
  borderColor: Colors.amber,
  borderWidth: 8,
  borderRadius: 20,
  borderLength: 40,
  overlayColor: Colors.black.withOpacity(0.6),
  cutOutSize: 280,
  successColor: Colors.greenAccent,
  errorColor: Colors.redAccent,
  //...
)
```

**New Code:**

You now group these properties into a `ScannerOverlayConfig` object.

```dart
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

AiBarcodeScanner(
  overlayConfig: const ScannerOverlayConfig(
    borderColor: Colors.amber,
    // Note: borderWidth is now part of the painter and not directly configurable
    // from the config. It has a fixed, well-proportioned value.
    borderRadius: 20,
    cornerLength: 40,
    backgroundBlurColor: Colors.black54, // Replaces overlayColor
    successColor: Colors.greenAccent,
    errorColor: Colors.redAccent,
    
    // New Options!
    scannerAnimation: ScannerAnimation.center, // or .fullWidth
    scannerBorder: ScannerBorder.corner, // or .full
  ),
  //...
)
```

### 2. Replace `DraggableSheet` with `bottomSheetBuilder`

If you were using `sheetTitle` or `sheetChild`, you now need to provide your own bottom sheet widget via `bottomSheetBuilder`.

**Old Code:**
```dart
AiBarcodeScanner(
  sheetTitle: "My Custom Title",
  sheetChild: MyCustomWidget(),
)
```

**New Code:**

Recreate the draggable sheet (or any other widget) using `bottomSheetBuilder`.

```dart
AiBarcodeScanner(
  bottomSheetBuilder: (context, controller) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.4,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              // Your custom drag handler, title, and child here
              Text("My Custom Title"),
              const Divider(),
              MyCustomWidget(),
            ],
          ),
        );
      },
    );
  },
)
```

### 3. Update Gallery Button Logic

The boolean flags `hideGalleryButton` and `hideGalleryIcon` are gone. Control the button's appearance with `galleryButtonType`.

**Old Code:**
```dart
// To show icon in AppBar
AiBarcodeScanner(
  hideGalleryIcon: false,
  hideGalleryButton: true,
)

// To show button at bottom
AiBarcodeScanner(
  hideGalleryIcon: true,
  hideGalleryButton: false,
)
```

**New Code:**
```dart
// To show icon in AppBar
AiBarcodeScanner(
  galleryButtonType: GalleryButtonType.icon,
)

// To show button at bottom (this is the default)
AiBarcodeScanner(
  galleryButtonType: GalleryButtonType.filled,
)
```

### 4. Parameter Mapping Table

| Old Parameter          | New Parameter / How to achieve                                         | Notes                                                                  |
| ---------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `borderColor`          | `overlayConfig.borderColor`                                            | Moved into `ScannerOverlayConfig`.                                     |
| `borderWidth`          | (Removed)                                                              | The border width is now fixed for a cleaner look.                      |
| `borderRadius`         | `overlayConfig.borderRadius`                                           | Moved into `ScannerOverlayConfig`.                                     |
| `borderLength`         | `overlayConfig.cornerLength`                                           | Renamed and moved into `ScannerOverlayConfig`.                         |
| `overlayColor`         | `overlayConfig.backgroundBlurColor`                                    | Moved and renamed for clarity. Now uses a blur effect.                 |
| `cutOutWidth`          | (Removed)                                                              | The scan window is now responsive by default. Use `scanWindow` for custom size. |
| `cutOutHeight`         | (Removed)                                                              | The scan window is now responsive by default. Use `scanWindow` for custom size. |
| `cutOutSize`           | (Removed)                                                              | Use the `scanWindow` parameter with a `Rect` for full control.         |
| `cutOutBottomOffset`   | (Removed)                                                              | The scan window is now centered by default. Use `scanWindow` for custom positioning. |
| `showError`            | `overlayConfig.animateOnError`                                         | Moved into `ScannerOverlayConfig`.                                     |
| `showSuccess`          | `overlayConfig.animateOnSuccess`                                       | Moved into `ScannerOverlayConfig`.                                     |
| `successColor`         | `overlayConfig.successColor`                                           | Moved into `ScannerOverlayConfig`.                                     |
| `errorColor`           | `overlayConfig.errorColor`                                             | Moved into `ScannerOverlayConfig`.                                     |
| `sheetTitle`           | Use `bottomSheetBuilder`                                               | Replaced by a more flexible builder.                                   |
| `sheetChild`           | Use `bottomSheetBuilder`                                               | Replaced by a more flexible builder.                                   |
| `hideSheetDragHandler` | Use `bottomSheetBuilder`                                               | Your custom bottom sheet now controls its own UI.                      |
| `hideSheetTitle`       | Use `bottomSheetBuilder`                                               | Your custom bottom sheet now controls its own UI.                      |
| `hideGalleryButton`    | Use `galleryButtonType`                                                | Replaced by the `galleryButtonType` enum.                              |
| `hideGalleryIcon`      | Use `galleryButtonType`                                                | Replaced by the `galleryButtonType` enum.                              |

The rest of the parameters like `onDetect`, `controller`, `validator`, and `onDispose` remain largely the same and should work as before. This refactoring has simplified the API while increasing its power and customizability.