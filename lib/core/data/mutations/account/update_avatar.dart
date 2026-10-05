import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

final useUpdateAvatar = Mutation<ApiResponse, File>(
  mutationFn: ApiService.uploadAvatar,
);
