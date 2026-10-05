import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'async_network_image_param.dart';

part 'async_network_image_provider.g.dart';

@riverpod
Future<String> asyncNetworkImage(Ref ref, AsyncNetworkImageParam param) async => param.load();
