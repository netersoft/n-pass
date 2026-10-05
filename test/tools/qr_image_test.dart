import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:n_pass/core/tools/functions/qr_image.dart';
import 'package:zxing2/qrcode.dart';

/// Renders [content] as a QR code PNG, like a screenshot of a setup page.
Uint8List qrPng(String content, {int scale = 8, int margin = 4}) {
  final matrix = Encoder.encode(content, ErrorCorrectionLevel.m).matrix!;
  final size = (matrix.width + 2 * margin) * scale;
  final image = img.Image(width: size, height: size)..clear(img.ColorRgb8(255, 255, 255));
  for (var y = 0; y < matrix.height; y++) {
    for (var x = 0; x < matrix.width; x++) {
      if (matrix.get(x, y) == 1) {
        img.fillRect(
          image,
          x1: (x + margin) * scale,
          y1: (y + margin) * scale,
          x2: (x + margin + 1) * scale - 1,
          y2: (y + margin + 1) * scale - 1,
          color: img.ColorRgb8(0, 0, 0),
        );
      }
    }
  }
  return img.encodePng(image);
}

void main() {
  const link = 'otpauth://totp/GitHub:jean%40example.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub';

  // Image decoding goes through the engine codecs: real async work.
  Future<String?> read(WidgetTester tester, Uint8List bytes) => tester.runAsync<String?>(() => readQrFromImage(bytes));

  testWidgets('reads the QR code of a PNG', (tester) async {
    expect(await read(tester, qrPng(link)), link);
  });

  testWidgets('reads it in a phone-sized JPEG screenshot, scaled down first', (tester) async {
    final page = img.Image(width: 1080, height: 2400)..clear(img.ColorRgb8(240, 240, 240));
    img.compositeImage(page, img.decodePng(qrPng(link, scale: 6))!, dstX: 120, dstY: 900);

    expect(await read(tester, img.encodeJpg(page, quality: 85)), link);
  });

  testWidgets('returns null for an image without a QR code, or a non-image', (tester) async {
    final blank = img.Image(width: 200, height: 200)..clear(img.ColorRgb8(255, 255, 255));

    expect(await read(tester, img.encodePng(blank)), isNull);
    expect(await read(tester, Uint8List.fromList([1, 2, 3])), isNull);
  });
}
