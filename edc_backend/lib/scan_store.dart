/// In-memory cache of completed scan results keyed by scanId.
/// Used by all scan routes to store results so GET /scan/[scanId] can
/// retrieve them after the initial POST returns.
/// In production this would be a database table.
final Map<String, Map<String, dynamic>> scanResultStore = {};
