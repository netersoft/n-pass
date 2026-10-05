import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../core/services/camera/service.dart';
import '../../../core/services/di/locator.dart';
import '../../../core/services/files/service.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/tools/functions/qr_image.dart';
import '../../../core/tools/functions/totp.dart';
import '../../themes/app_theme.dart';

enum _CameraAccess { pending, allowed, denied }

/// Reads a 2FA QR code with the camera, or from an imported screenshot.
/// Pops with the `otpauth://` link, or null when the user goes back.
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> with WidgetsBindingObserver {
  final _camera = locator<CameraPermissionService>();
  final _qrKey = GlobalKey(debugLabel: 'qr');
  StreamSubscription<Barcode>? _scans;
  _CameraAccess _access = _CameraAccess.pending;
  bool _done = false;
  bool _importing = false;
  String? _lastRejected;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _camera.request().then((allowed) {
      if (mounted) setState(() => _access = allowed ? _CameraAccess.allowed : _CameraAccess.denied);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scans?.cancel();
    super.dispose();
  }

  /// Back from the system settings: picks up a newly granted camera.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _access != _CameraAccess.denied) return;
    _camera.check().then((allowed) {
      if (allowed && mounted) setState(() => _access = _CameraAccess.allowed);
    });
  }

  void _onCreated(QRViewController controller) {
    _scans = controller.scannedDataStream.listen((barcode) {
      final code = barcode.code;
      if (code == null) return;
      if (_accept(code)) {
        controller.pauseCamera();
      } else if (code != _lastRejected && mounted) {
        // The same wrong code is reported many times per second.
        _lastRejected = code;
        _snack(context.t.notTotpQr);
      }
    });
  }

  /// Closes with [code] when it is a usable 2FA link.
  bool _accept(String code) {
    if (_done || !code.trim().toLowerCase().startsWith('otpauth://') || parseTotpInput(code) == null) return false;
    _done = true;
    context.pop(code.trim());
    return true;
  }

  Future<void> _importImage() async {
    setState(() => _message = null);
    final bytes = await locator<FileTransferService>().pickImage();
    if (bytes == null || !mounted) return;
    setState(() => _importing = true);
    String? code;
    try {
      code = await readQrFromImage(bytes);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
    if (!mounted) return;
    if (code == null) {
      _snack(context.t.noQrInImage);
    } else if (!_accept(code)) {
      _snack(context.t.notTotpQr);
    }
  }

  /// Shown in the screen until the next import, rather than as a timed
  /// snackbar: coming back from the image picker, the app stays inactive
  /// (privacy cover on) while the camera restarts, which would hide it.
  void _snack(String text) => setState(() => _message = text);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: AppTheme.getAppbarBgColor(),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(context.t.scanQrCode, style: const TextStyle(color: Colors.white)),
    ),
    body: Stack(
      children: [
        if (_access == _CameraAccess.allowed)
          QRView(
            key: _qrKey,
            formatsAllowed: const [BarcodeFormat.qrcode],
            overlay: QrScannerOverlayShape(borderColor: Colors.white, borderRadius: 12, borderLength: 32, borderWidth: 8, cutOutSize: 260),
            onQRViewCreated: _onCreated,
            onPermissionSet: (_, allowed) => setState(() => _access = allowed ? _CameraAccess.allowed : _CameraAccess.denied),
          )
        else if (_access == _CameraAccess.denied)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_photography_outlined, color: Colors.white70, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    context.t.cameraDenied,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                    onPressed: _camera.openSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(context.t.openSettings),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_access == _CameraAccess.allowed)
                  Text(
                    context.t.scanQrHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)]),
                  ),
                if (_message case final message?) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(message, style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _importing ? null : _importImage,
                  icon: _importing ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.image_outlined),
                  label: Text(context.t.importImage),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
