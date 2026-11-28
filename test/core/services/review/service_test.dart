import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/helpers/ui/rate_dialog.dart';
import 'package:n_pass/core/services/di/locator.dart';
import 'package:n_pass/core/services/review/service.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';
import 'package:n_pass/core/services/shared_preferences/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService prefs;
  late int sheets;
  late int dialogs;
  late int listings;
  late DateTime now;
  bool? answer;
  RateChoice? choice;

  ReviewService service({bool android = true}) => ReviewService(
    now: () => now,
    isAndroid: android,
    ask: () async {
      dialogs++;
      return choice;
    },
    openListing: () async => listings++,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = (await SharedPreferencesService.getInstance())!;
    // The service keeps its SharedPreferences instance across tests.
    for (final key in [PrefKeys.reviewRequested, PrefKeys.reviewRequestedAt, PrefKeys.rateDialogCount, PrefKeys.rateDialogLastAt, PrefKeys.rateDone]) {
      await prefs.remove(key);
    }
    locator.registerSingleton<SharedPreferencesService>(prefs);
    sheets = 0;
    dialogs = 0;
    listings = 0;
    now = DateTime(2026);
    answer = true;
    choice = RateChoice.later;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReviewService.channel, (call) async {
      sheets++;
      return answer;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReviewService.channel, null);
    locator.unregister<SharedPreferencesService>();
  });

  test('requests the review sheet first, never our dialog straight after it', () async {
    await service().requestOnce();
    now = now.add(const Duration(days: 1));
    await service().requestOnce();

    expect(sheets, 1);
    expect(dialogs, 0);
    expect(prefs.getBool(PrefKeys.reviewRequested), isTrue);
  });

  test('asks again later when the review flow could not start', () async {
    answer = false;
    await service().requestOnce();
    answer = true;
    await service().requestOnce();

    expect(sheets, 2);
    expect(dialogs, 0);
    expect(prefs.getBool(PrefKeys.reviewRequested), isTrue);
  });

  test('shows the store dialog after the delay, at most 3 times and 30 days apart', () async {
    await service().requestOnce();
    now = now.add(ReviewService.dialogDelay);
    await service().requestOnce();
    expect(dialogs, 1);

    now = now.add(const Duration(days: 10));
    await service().requestOnce();
    expect(dialogs, 1, reason: 'too soon');

    for (var i = 0; i < 4; i++) {
      now = now.add(ReviewService.dialogGap);
      await service().requestOnce();
    }
    expect(dialogs, ReviewService.maxDialogs);
    expect(listings, 0);
  });

  test('opens the listing and stops asking once the user accepts', () async {
    await service().requestOnce();
    now = now.add(ReviewService.dialogDelay);
    choice = RateChoice.rate;
    await service().requestOnce();
    now = now.add(const Duration(days: 90));
    await service().requestOnce();

    expect(dialogs, 1);
    expect(listings, 1);
  });

  test('stops asking once the user opts out', () async {
    await service().requestOnce();
    now = now.add(ReviewService.dialogDelay);
    choice = RateChoice.never;
    await service().requestOnce();
    now = now.add(const Duration(days: 90));
    await service().requestOnce();

    expect(dialogs, 1);
    expect(listings, 0);
  });

  test('iOS keeps the system sheet only', () async {
    await service(android: false).requestOnce();
    now = now.add(const Duration(days: 90));
    await service(android: false).requestOnce();

    expect(sheets, 1);
    expect(dialogs, 0);
  });
}
