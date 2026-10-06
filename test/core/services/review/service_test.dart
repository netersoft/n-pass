import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/services/di/locator.dart';
import 'package:n_pass/core/services/review/service.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';
import 'package:n_pass/core/services/shared_preferences/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService prefs;
  late int calls;
  bool? answer;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = (await SharedPreferencesService.getInstance())!;
    // The service keeps its SharedPreferences instance across tests.
    await prefs.setBool(PrefKeys.reviewRequested, false);
    locator.registerSingleton<SharedPreferencesService>(prefs);
    calls = 0;
    answer = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReviewService.channel, (call) async {
      calls++;
      return answer;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReviewService.channel, null);
    locator.unregister<SharedPreferencesService>();
  });

  test('requests the review sheet once, then never again', () async {
    await ReviewService().requestOnce();
    await ReviewService().requestOnce();

    expect(calls, 1);
    expect(prefs.getBool(PrefKeys.reviewRequested), isTrue);
  });

  test('asks again later when the review flow could not start', () async {
    answer = false;
    await ReviewService().requestOnce();
    answer = true;
    await ReviewService().requestOnce();

    expect(calls, 2);
    expect(prefs.getBool(PrefKeys.reviewRequested), isTrue);
  });
}
