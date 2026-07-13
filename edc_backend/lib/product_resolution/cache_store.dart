/// Cache interface for [ProductResolutionService].
///
/// ## Redis migration path
///
/// The only interface change needed is the optional [ttl] parameter on [set],
/// which is already here. To swap in Redis:
///
///   1. Add `redis` (or `resp3`) to pubspec.yaml.
///   2. Implement `RedisCacheStore<V>` below:
///
///      ```dart
///      class RedisCacheStore<V> implements CacheStore<V> {
///        RedisCacheStore(this._client, this._serialize, this._deserialize);
///        final RedisClient _client;
///        final String Function(V) _serialize;
///        final V Function(String) _deserialize;
///
///        @override
///        Future<V?> get(String key) async {
///          final raw = await _client.get(key);
///          return raw == null ? null : _deserialize(raw);
///        }
///
///        @override
///        Future<void> set(String key, V value, {Duration? ttl}) async {
///          await _client.set(key, _serialize(value));
///          if (ttl != null) await _client.expire(key, ttl.inSeconds);
///        }
///
///        @override
///        Future<void> delete(String key) => _client.del(key);
///      }
///      ```
///
///   3. In `routes/scan/middleware.dart`, replace `InMemoryCacheStore()` with
///      `RedisCacheStore(redisClient, serialize, deserialize)`.
///      [ProductResolutionService] and all callers are unchanged.
///
/// ## What stays in-memory vs moves to Redis
///
/// | Store              | Move to Redis? | Reason |
/// |--------------------|----------------|--------|
/// | CacheStore<ProductResolution> (barcode cache) | YES | Survives restarts; shared across instances; barcodes are looked up repeatedly |
/// | EdcCache (List<EdcEntry>)  | NO  | Loaded from Postgres on startup/refresh; small dataset; Redis adds no benefit over in-process list |
/// | RateLimiter._store | YES (later) | Must be shared across instances for correctness; use Redis ZSET |
abstract interface class CacheStore<V> {
  Future<V?> get(String key);

  /// [ttl] is ignored by [InMemoryCacheStore] but honoured by Redis
  /// implementations. Pass it now so call sites don't need to change later.
  Future<void> set(String key, V value, {Duration? ttl});

  Future<void> delete(String key);
}

/// In-memory implementation. TTL is not enforced — entries live until
/// [delete] is called or the process restarts.
class InMemoryCacheStore<V> implements CacheStore<V> {
  final _store = <String, V>{};

  @override
  Future<V?> get(String key) async => _store[key];

  @override
  Future<void> set(String key, V value, {Duration? ttl}) async =>
      _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);
}
