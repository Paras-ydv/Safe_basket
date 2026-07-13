abstract interface class CacheStore<V> {
  Future<V?> get(String key);
  Future<void> set(String key, V value);
  Future<void> delete(String key);
}

/// In-memory implementation. Swap for a Redis-backed class without touching
/// [resolveBarcode].
class InMemoryCacheStore<V> implements CacheStore<V> {
  final _store = <String, V>{};

  @override
  Future<V?> get(String key) async => _store[key];

  @override
  Future<void> set(String key, V value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);
}
