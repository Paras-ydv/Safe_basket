import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';
import 'package:edc_backend/user_id_middleware.dart';
import '../main.dart' show edcCache;

final _config = AppConfig.load();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<AppConfig>((_) => _config))
      .use(provider<EdcCache>((_) => edcCache))
      .use(userIdMiddleware);
}
