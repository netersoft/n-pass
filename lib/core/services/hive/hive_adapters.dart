import 'package:hive_ce/hive.dart';

import '../../enums/app_brightness.dart';
import '../../enums/image_size.dart';
import '../../models/user_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<UserModel>(),
  AdapterSpec<AppBrightness>(),
  AdapterSpec<ImageSize>(),
], firstTypeId: 100)
class HiveAdapters {}
