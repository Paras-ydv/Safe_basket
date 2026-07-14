import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';
import 'package:edc_backend/user_id_middleware.dart';

final _config = AppConfig.load();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<AppConfig>((_) => _config))
      .use(userIdMiddleware);
}
