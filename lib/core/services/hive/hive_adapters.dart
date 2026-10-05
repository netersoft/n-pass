import 'package:hive_ce/hive.dart';

import '../../enums/app_brightness.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<AppBrightness>(),
])
class HiveAdapters {}
