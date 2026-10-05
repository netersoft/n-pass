import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/api/service.dart';

part 'global_provider.g.dart';

@riverpod
class Global extends _$Global {
  @override
  GlobalState build() => const GlobalState();

  Future<bool> checkConnectivity() async {
    if (state.checkingConnectionLocked) return false;

    state = state.copyWith(isCheckingConnection: true);

    var list = await Connectivity().checkConnectivity();

    state = state.copyWith(
      isConnected: !list.contains(ConnectivityResult.none),
      isCheckingConnection: false,
      checkingConnectionLocked: true,
    );

    return state.isConnected;
  }

  Future<bool> checkServerAvailability() async {
    if (state.checkingServerLocked) return false;

    state = state.copyWith(isCheckingServer: true);

    var response = await ApiService.makeRequest(path: '/');

    state = state.copyWith(
      isServerAvailable: response.isSuccess,
      isCheckingServer: false,
      checkingServerLocked: true,
    );

    return state.isServerAvailable;
  }

  Future<bool> checkDatabaseAvailability() async {
    if (state.checkingDatabaseLocked) return false;

    state = state.copyWith(isCheckingDatabase: true);

    var response = await ApiService.makeRequest(path: '/database');

    state = state.copyWith(
      isDatabaseAvailable: response.isSuccess,
      isCheckingDatabase: false,
      checkingDatabaseLocked: true,
    );

    return state.isDatabaseAvailable;
  }

  void rebuild() {
    state = state.copyWith(
      checkingConnectionLocked: false,
      checkingServerLocked: false,
      checkingDatabaseLocked: false,
    );
  }
}

class GlobalState {
  final bool isConnected;
  final bool isServerAvailable;
  final bool isDatabaseAvailable;
  final bool isCheckingConnection;
  final bool isCheckingServer;
  final bool isCheckingDatabase;
  final bool checkingConnectionLocked;
  final bool checkingServerLocked;
  final bool checkingDatabaseLocked;

  const GlobalState({
    this.isConnected = false,
    this.isServerAvailable = false,
    this.isDatabaseAvailable = false,
    this.isCheckingConnection = false,
    this.isCheckingServer = false,
    this.isCheckingDatabase = false,
    this.checkingConnectionLocked = false,
    this.checkingServerLocked = false,
    this.checkingDatabaseLocked = false,
  });

  GlobalState copyWith({
    bool? isConnected,
    bool? isServerAvailable,
    bool? isDatabaseAvailable,
    bool? isCheckingConnection,
    bool? isCheckingServer,
    bool? isCheckingDatabase,
    bool? checkingConnectionLocked,
    bool? checkingServerLocked,
    bool? checkingDatabaseLocked,
  }) => GlobalState(
    isConnected: isConnected ?? this.isConnected,
    isServerAvailable: isServerAvailable ?? this.isServerAvailable,
    isDatabaseAvailable: isDatabaseAvailable ?? this.isDatabaseAvailable,
    isCheckingConnection: isCheckingConnection ?? this.isCheckingConnection,
    isCheckingServer: isCheckingServer ?? this.isCheckingServer,
    isCheckingDatabase: isCheckingDatabase ?? this.isCheckingDatabase,
    checkingConnectionLocked: checkingConnectionLocked ?? this.checkingConnectionLocked,
    checkingServerLocked: checkingServerLocked ?? this.checkingServerLocked,
    checkingDatabaseLocked: checkingDatabaseLocked ?? this.checkingDatabaseLocked,
  );
}
