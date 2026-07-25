// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyRepositoryHash() => r'f1bf644e84c5e95aece457469cc2fc6a1540a808';

/// Binding for the [HistoryRepository]. Binds the real Dio-backed repo by
/// default; falls back to the fake with `--dart-define=USE_FAKES=true`.
///
/// Copied from [historyRepository].
@ProviderFor(historyRepository)
final historyRepositoryProvider =
    AutoDisposeProvider<HistoryRepository>.internal(
      historyRepository,
      name: r'historyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryRepositoryRef = AutoDisposeProviderRef<HistoryRepository>;
String _$historyListHash() => r'cbaae0a00c4b54d18a200956b6c81667f8f6f109';

/// Full scan history for the History tab (newest first).
///
/// Copied from [historyList].
@ProviderFor(historyList)
final historyListProvider =
    AutoDisposeFutureProvider<List<ScanResult>>.internal(
      historyList,
      name: r'historyListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistoryListRef = AutoDisposeFutureProviderRef<List<ScanResult>>;
String _$trendsHash() => r'39230b4d493e3918f155fe136b7b3327c8afd5e6';

/// Aggregated [Trends] for the Trends tab. Counts stored results only — it does
/// not recompute any risk category (§5.6).
///
/// Copied from [trends].
@ProviderFor(trends)
final trendsProvider = AutoDisposeFutureProvider<Trends>.internal(
  trends,
  name: r'trendsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrendsRef = AutoDisposeFutureProviderRef<Trends>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
