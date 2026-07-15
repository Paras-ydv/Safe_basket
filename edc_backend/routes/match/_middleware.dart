import 'package:dart_frog/dart_frog.dart';
import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/edc_repository/edc_cache.dart';

Handler middleware(Handler handler) {
  return (context) {
    final entries = context.read<EdcCache>().entries;
    return handler
        .use(provider<List<EdcEntry>>((_) => entries))
        .call(context);
  };
}
