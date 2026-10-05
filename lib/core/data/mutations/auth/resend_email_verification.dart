import 'package:cached_query_flutter/cached_query_flutter.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

final useResendEmailVerification = Mutation<ApiResponse, void>(
  mutationFn: (_) => ApiService.makeRequest(
    path: '/email/verification-notification',
    type: RequestType.post,
  ),
);
