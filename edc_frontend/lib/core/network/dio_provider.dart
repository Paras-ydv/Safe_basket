import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/shared_preferences_provider.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import 'envelope_interceptor.dart';

part 'dio_provider.g.dart';

const _deviceIdKey = 'device_id';

/// A stable per-install id sent as `X-User-Id` until real auth lands.
String _deviceId(DioRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final existing = prefs.getString(_deviceIdKey);
  if (existing != null) return existing;
  final id =
      'dev-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(0x7fffffff)}';
  prefs.setString(_deviceIdKey, id);
  return id;
}

/// The configured [Dio] client used by all repositories. Keep-alive so a single
/// client (and its connection pool) is shared app-wide.
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final userId = _deviceId(ref);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(() => userId),
    EnvelopeInterceptor(),
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: false),
  ]);

  return dio;
}
