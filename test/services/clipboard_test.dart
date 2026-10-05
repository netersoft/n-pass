import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/services/clipboard/service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = MethodChannel('npass/clipboard');

  late List<MethodCall> nativeCalls;
  late String? systemClipboard;

  setUp(() {
    nativeCalls = [];
    systemClipboard = null;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') systemClipboard = (call.arguments as Map)['text'] as String?;
      return null;
    });
  });

  tearDown(() {
    messenger
      ..setMockMethodCallHandler(SystemChannels.platform, null)
      ..setMockMethodCallHandler(channel, null);
  });

  test('plain values go to the system clipboard', () async {
    await ClipboardService().copy('jean.dupont');

    expect(systemClipboard, 'jean.dupont');
  });

  test('secrets go through the native channel with the clear delay', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      nativeCalls.add(call);
      return null;
    });

    await ClipboardService().copy('s3cret', sensitive: true);

    expect(nativeCalls.single.method, 'copySensitive');
    expect(nativeCalls.single.arguments, {'text': 's3cret', 'clearAfterMs': 30000});
    expect(systemClipboard, isNull);
  });

  test('secrets fall back to the system clipboard without the native channel', () async {
    await ClipboardService().copy('s3cret', sensitive: true);

    expect(systemClipboard, 's3cret');
  });
}
