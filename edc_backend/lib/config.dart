import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class AppConfig {
  AppConfig._({
    required this.dbConnectionString,
    required this.ocrApiKey,
    required this.ocrApiUrl,
    required this.port,
  });

  final String dbConnectionString;
  final String ocrApiKey;
  final String ocrApiUrl;
  final int port;

  static AppConfig load() {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    return AppConfig._(
      dbConnectionString: env['DB_CONNECTION_STRING'] ?? '',
      ocrApiKey: env['OCR_API_KEY'] ?? '',
      ocrApiUrl: env['OCR_API_URL'] ?? '',
      port: int.tryParse(env['PORT'] ?? '8080') ?? 8080,
    );
  }

  /// Opens a single [Connection] from [dbConnectionString].
  /// Callers are responsible for closing it.
  Future<Connection> openConnection() {
    final uri = Uri.parse(dbConnectionString);
    return Connection.open(
      Endpoint(
        host: uri.host,
        port: uri.port == 0 ? 5432 : uri.port,
        database: uri.pathSegments.first,
        username: uri.userInfo.split(':').first,
        password:
            uri.userInfo.contains(':') ? uri.userInfo.split(':').last : null,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
}
