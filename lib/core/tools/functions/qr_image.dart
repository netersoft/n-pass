import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:zxing2/qrcode.dart';

/// Longest side images are scaled down to before looking for a QR code: a QR
/// code in a screenshot stays readable at this size.
const int maxQrImageSide = 1024;

/// Pixels handed to [decodeQrPixels], as 0xAARRGGBB values.
typedef QrPixels = ({int width, int height, Int32List argb});

/// Reads the QR code in an image file (PNG, JPEG, WebP...), e.g. a screenshot
/// of a 2FA setup page. Returns null when the file is not an image or holds no
/// readable QR code.
///
/// The image is decoded (and scaled down) by the engine's native codecs, much
/// faster than in Dart; only the QR search runs in a background isolate.
Future<String?> readQrFromImage(Uint8List bytes) async {
  final QrPixels pixels;
  try {
    pixels = await _decodePixels(bytes);
  } on Object {
    // Not an image, or a format the platform can't decode.
    return null;
  }
  return compute(decodeQrPixels, pixels);
}

Future<QrPixels> _decodePixels(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final longest = descriptor.width > descriptor.height ? descriptor.width : descriptor.height;
  final scale = longest > maxQrImageSide ? maxQrImageSide / longest : 1.0;
  final codec = await descriptor.instantiateCodec(
    targetWidth: (descriptor.width * scale).round(),
    targetHeight: (descriptor.height * scale).round(),
  );
  final image = (await codec.getNextFrame()).image;
  final rgba = (await image.toByteData())!.buffer.asUint8List();
  final argb = Int32List(image.width * image.height);
  for (var i = 0, p = 0; i < argb.length; i++, p += 4) {
    argb[i] = 0xff000000 | (rgba[p] << 16) | (rgba[p + 1] << 8) | rgba[p + 2];
  }
  final result = (width: image.width, height: image.height, argb: argb);
  image.dispose();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return result;
}

/// Looks for a QR code in [pixels]: cheapest attempt first, tryHarder only as
/// a last resort. Pure Dart, safe to run in an isolate.
String? decodeQrPixels(QrPixels pixels) {
  final source = RGBLuminanceSource(pixels.width, pixels.height, pixels.argb);
  final attempts = [
    (HybridBinarizer(source), DecodeHints()),
    (HybridBinarizer(source), DecodeHints()..put(DecodeHintType.tryHarder)),
    (GlobalHistogramBinarizer(source), DecodeHints()..put(DecodeHintType.tryHarder)),
  ];
  for (final (binarizer, hints) in attempts) {
    try {
      return QRCodeReader().decode(BinaryBitmap(binarizer), hints: hints).text;
    } on ReaderException {
      continue;
    }
  }
  return null;
}
