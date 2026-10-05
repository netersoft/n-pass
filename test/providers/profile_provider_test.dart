import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/models/user_model.dart';
import 'package:flutter_starter/core/providers/account/profile_provider.dart';
import 'package:flutter_starter/core/services/api/response.dart';
import 'package:flutter_starter/core/services/api/service.dart';
import 'package:flutter_starter/core/services/hive/hive_registrar.g.dart';
import 'package:flutter_starter/core/services/hive/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_utils.dart';

void main() {
  late Directory tempDir;
  late Box authBox;
  late MockApiClient mockApiClient;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_profile_provider_test');
    Hive
      ..init(tempDir.path)
      ..registerAdapters();
    // Profile reads/writes `Hive.box(HiveKeys.auth)` directly and expects it
    // already open -- same assumption as production, minus the encryption
    // cipher these tests never touch.
    authBox = await Hive.openBox(HiveKeys.auth);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    mockApiClient = MockApiClient();
    await setupTestLocator(apiClient: mockApiClient);
  });

  tearDown(() async {
    await authBox.clear();
    teardownTestLocator();
  });

  UserModel buildUser({String? name, String? email}) => UserModel(
    id: 1,
    name: name ?? 'Jane Doe',
    email: email ?? 'jane@example.com',
  );

  group('updateProfile', () {
    test('persists the updated user to Hive and state on success', () async {
      await authBox.put(HiveKeys.authUserData, buildUser());

      when(
        () => mockApiClient.makeRequest(
          type: RequestType.patch,
          path: '/profile',
          data: any(named: 'data'),
          useApiUrl: any(named: 'useApiUrl'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse(
          statusCode: 200,
          message: null,
          data: {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'},
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container.read(profileProvider.notifier).updateProfile(name: 'John Doe', email: 'john@example.com');

      expect(success, isTrue);
      expect(container.read(profileProvider).userData?.name, 'John Doe');
      expect(container.read(profileProvider).userData?.email, 'john@example.com');
      expect(container.read(profileProvider).isUpdatingProfile, isFalse);

      final storedUser = authBox.get(HiveKeys.authUserData) as UserModel;
      expect(storedUser.name, 'John Doe');
    });

    test('returns false and forwards field errors on a 422 without touching Hive', () async {
      await authBox.put(HiveKeys.authUserData, buildUser());

      when(
        () => mockApiClient.makeRequest(
          type: RequestType.patch,
          path: '/profile',
          data: any(named: 'data'),
          useApiUrl: any(named: 'useApiUrl'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse(
          statusCode: 422,
          message: 'The given data was invalid.',
          errors: {
            'email': ['already used'],
          },
        ),
      );
      when(() => mockApiClient.displayFormErrors(any())).thenReturn(null);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = await container.read(profileProvider.notifier).updateProfile(name: 'Jane Doe', email: 'taken@example.com');

      expect(success, isFalse);
      expect(container.read(profileProvider).userData?.email, 'jane@example.com');
      verify(
        () => mockApiClient.displayFormErrors({
          'email': ['already used'],
        }),
      ).called(1);
    });
  });
}
