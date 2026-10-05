import 'package:cached_query_flutter/cached_query_flutter.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

final useForgotPassword = Mutation<ApiResponse, String>(
  mutationFn: (email) => ApiService.makeRequest(
    path: '/forgot-password',
    type: RequestType.post,
    data: {'email': email},
  ),
);
