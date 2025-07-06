# AI Barcode Scanner

<p>
  <a href="https://pub.dev/packages/ai_barcode_scanner"><img src="https://img.shields.io/pub/v/ai_barcode_scanner.svg" alt="Pub Version"></a>
  <a href="https://github.com/sponsors/juliansteenbakker"><img src="https://img.shields.io/github/sponsors/juliansteenbakker?label=Sponsor%20mobile_scanner" alt="Sponsor"></a>
  <a href="https://github.com/itsarvinddev/barcode_scanner/blob/main/LICENSE"><img src="https://img.shields.io/github/license/itsarvinddev/barcode_scanner" alt="License"></a>
</p>

A powerful and customizable barcode scanner for Flutter, built on top of the excellent `mobile_scanner` package. This widget provides a complete, ready-to-use screen for all your barcode scanning needs, with a beautiful and modern UI.

> **Screenshots**: [AI Barcode Scanner](https://github.com/itsarvinddev/barcode_scanner/blob/main/assets/)

<img src="https://raw.githubusercontent.com/itsarvinddev/barcode_scanner/master/assets/ai_barcode_scanner.png" alt="">

## ✨ Features

- **Modern & Customizable UI**: Clean, modern interface that can be deeply customized.
- **Pinch-to-Zoom**: Smoothly zoom the camera with a two-finger pinch gesture.
- **Flashlight & Camera Switch**: Easy-to-use controls for the torch and for switching between front and back cameras.
- **Gallery Support**: Scan barcodes from images in the user's gallery.
- **Customizable Overlay**: Change the border style (corners or full), colors, animation, and more with a simple configuration object.
- **Validation Feedback**: The overlay provides instant visual feedback (e.g., green for success, red for error) that automatically resets.
- **Advanced Configuration**: Full access to the underlying `MobileScannerController` for advanced use cases like setting specific barcode formats.

---

## Platform Support

| Android | iOS | macOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️    | ✔️  |  ✔️   | ✔️  |  ❌   |   ❌    |

> **Note**: This package relies on `mobile_scanner`, which does not support Windows or Linux. Attempting to use it on these platforms will display a "not supported" message.

---

## 🔧 Under the Hood: `mobile_scanner`

This package is a high-level, opinionated wrapper around the powerful [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) package. It's designed to provide a complete, ready-to-use scanner screen with minimal setup.

For advanced use cases, deep customization, or troubleshooting platform-specific issues, **we highly recommend reading the `mobile_scanner` documentation**. You'll find detailed information on:

- Advanced controller settings (`detectionSpeed`, `torch`, etc.).
- Handling the camera lifecycle manually.
- Detailed platform-specific configuration.
- Understanding the raw data returned from the scanner.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have completed the platform-specific setup for the `mobile_scanner` package. This usually involves adding camera usage descriptions to your `Info.plist` on iOS.

**iOS (`ios/Runner/Info.plist`)**:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan barcodes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to scan barcodes from images.</string>
```

For detailed platform setup, please refer to the [official mobile_scanner documentation](https://pub.dev/packages/mobile_scanner#platform-specific-setup).

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ai_barcode_scanner: ^latest_version # Replace with the latest version
```

### Basic Usage

Import the package and use the `AiBarcodeScanner` widget. It's a complete screen widget, so you'll typically push it onto the `Navigator` stack.

```dart
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';

// ... in your widget
ElevatedButton(
  onPressed: () async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
          onDetect: (BarcodeCapture capture) {
            // Handle the scanned barcode
            debugPrint("Barcode detected: ${capture.barcodes.first.rawValue}");
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  },
  child: const Text("Scan Barcode"),
)
```

### Advanced Usage with Validation and Controller

You can provide a `MobileScannerController` for more control and a `validator` function for real-time feedback.

```dart
AiBarcodeScanner(
  // Use a controller to customize formats, detection speed, etc.
  controller: MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  ),
  // Validate the scanned barcode
  validator: (value) {
    return value.barcodes.first.rawValue?.contains("your_prefix") ?? false;
  },
  onDetect: (BarcodeCapture capture) {
    // This callback is only called if the validation is successful
    print('Valid barcode detected: ${capture.barcodes.first.rawValue}');
    Navigator.of(context).pop();
  },
)
```

---

## 🎨 Customization

The scanner's appearance and behavior are highly customizable through the `AiBarcodeScanner` widget's parameters.

### Customizing the Overlay

The overlay (border, background, and animation) is controlled by the `overlayConfig` parameter, which takes a `ScannerOverlayConfig` object.

```dart
AiBarcodeScanner(
  overlayConfig: const ScannerOverlayConfig(
    // Change the animation style
    scannerAnimation: ScannerAnimation.fullWidth,
    // Change the border style
    scannerBorder: ScannerBorder.full,
    // Customize colors
    borderColor: Colors.blue,
    successColor: Colors.teal,
    errorColor: Colors.orange,
    // Adjust corner radius
    borderRadius: 24,
    cornerLength: 50,
  ),
  // ...
)
```

### Customizing the Gallery Button

You can change the style and text of the gallery button.

```dart
AiBarcodeScanner(
  // Use an icon in the AppBar instead of a filled button
  galleryButtonType: GalleryButtonType.icon,
  // Or customize the text of the filled button
  galleryButtonText: "Choose from Photos",
  // ...
)
```

### All Configuration Options

Here are the key parameters for `AiBarcodeScanner`:

| Parameter                     | Type                       | Description                                                                  |
| ----------------------------- | -------------------------- | ---------------------------------------------------------------------------- |
| **`onDetect`**                | `Function(BarcodeCapture)` | **Required.** Callback for when a barcode is detected and validated.         |
| **`validator`**               | `Function(BarcodeCapture)` | Optional function to validate a barcode. Returns `true` for valid.           |
| **`controller`**              | `MobileScannerController`  | Optional controller for advanced settings (e.g., barcode formats).           |
| **`overlayConfig`**           | `ScannerOverlayConfig`     | Configuration for the visual overlay (colors, borders, animation).           |
| **`onImagePick`**             | `Function(String?)`        | Callback when an image is picked from the gallery.                           |
| **`appBarBuilder`**           | `Function(...)`            | A builder to create a completely custom `AppBar`.                            |
| **`bottomSheetBuilder`**      | `Function(...)`            | A builder to add a custom bottom sheet to the scanner screen.                |
| **`colorTransitionDuration`** | `Duration`                 | How long the success/error color stays before reverting. Default is `500ms`. |
| **`galleryButtonType`**       | `GalleryButtonType`        | Style of the gallery button (`.filled` or `.icon`).                          |
| **`galleryButtonText`**       | `String`                   | Text for the filled gallery button.                                          |
| **`onDispose`**               | `Function()`               | Callback when the scanner widget is disposed.                                |
| **`scanWindow`**              | `Rect`                     | A specific `Rect` to restrict the scanning area.                             |

---

## 🆘 Troubleshooting

- **Scanner doesn't start / Black Screen**: Ensure you have requested camera permissions and have correctly configured your `Info.plist` (for iOS) or `AndroidManifest.xml`.
- **Incorrect Scans**: This can happen with distant or poorly lit barcodes. This is a known limitation of the underlying MLKit library. Try to scan closer and in better light.
- **iOS Pods Issues**: If you face issues with CocoaPods, especially with other packages like Firebase, try cleaning your workspace: `flutter clean`, remove `Podfile.lock`, and run `pod install --repo-update` in your `ios` directory.

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue. If you want to contribute code, please open a pull request.

<a href="https://github.com/mohesu/barcode_scanner/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mohesu/barcode_scanner" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

## ❤️ Acknowledgements

This package is a wrapper around and stands on the shoulders of the amazing `mobile_scanner` package by Julian Steenbakker. A huge thanks to him and all contributors to that project.
