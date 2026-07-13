import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/config.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final config = AppConfig.load();
  return serve(handler, ip, config.port);
}
