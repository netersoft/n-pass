import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  }

  await bootstrapApp(
    config: const AppBootstrapConfig(skipBindingInit: kDebugMode),
  );

  runApp(ProviderScope(child: Phoenix(child: const App())));
}
