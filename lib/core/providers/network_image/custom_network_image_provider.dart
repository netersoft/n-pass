import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../tools/functions/url_functions.dart';
import 'custom_network_image_param.dart';

part 'custom_network_image_provider.g.dart';

@riverpod
Future<String> customNetworkImage(Ref ref, CustomNetworkImageParam param) async => getImageUrl(param.src, size: param.size);
