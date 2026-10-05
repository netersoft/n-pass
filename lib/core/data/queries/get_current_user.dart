import 'package:cached_query_flutter/cached_query_flutter.dart';

import '../../models/user_model.dart';
import '../../services/api/service.dart';

Query<UserModel?> useCurrentUser() => Query<UserModel?>(
  key: ['current-user'],
  queryFn: () async {
    var response = await ApiService.makeRequest(path: '/user');

    if (response.isSuccess) {
      return UserModel.fromJson(response.data);
    }

    return null;
  },
);
