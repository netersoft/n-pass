import 'package:cached_query_flutter/cached_query_flutter.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

final useLogout = Mutation<ApiResponse, void>(
  mutationFn: (_) => ApiService.makeRequest(
    path: '/logout',
    type: RequestType.post,
  ),
);
