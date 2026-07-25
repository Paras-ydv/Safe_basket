import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../domain/app_notification.dart';
import 'notifications_repository.dart';

/// Dio-backed [NotificationsRepository] hitting `GET /notifications`.
class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      // dynamic: unwrap the envelope to a List via the EnvelopeInterceptor.
      final res = await _dio.get<dynamic>('/notifications');
      final list = (res.data as List<dynamic>?) ?? const [];
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
