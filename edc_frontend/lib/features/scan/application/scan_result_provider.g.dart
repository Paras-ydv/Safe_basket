// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanRepositoryHash() => r'b742fe6beb3cd1a6e1c81009f24d8c50b8c3b99b';

/// Binding for the [ScanRepository]. Binds the real Dio-backed repo by default;
/// falls back to the fake with `--dart-define=USE_FAKES=true`.
///
/// Copied from [scanRepository].
@ProviderFor(scanRepository)
final scanRepositoryProvider = AutoDisposeProvider<ScanRepository>.internal(
  scanRepository,
  name: r'scanRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scanRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScanRepositoryRef = AutoDisposeProviderRef<ScanRepository>;
String _$scanResultHash() => r'9f01fe784c885cd082276ea2b2ae4db23714c73d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
/// only — the fetch lives in the repository (§4.1).
///
/// Copied from [scanResult].
@ProviderFor(scanResult)
const scanResultProvider = ScanResultFamily();

/// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
/// only — the fetch lives in the repository (§4.1).
///
/// Copied from [scanResult].
class ScanResultFamily extends Family<AsyncValue<ScanResult>> {
  /// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
  /// only — the fetch lives in the repository (§4.1).
  ///
  /// Copied from [scanResult].
  const ScanResultFamily();

  /// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
  /// only — the fetch lives in the repository (§4.1).
  ///
  /// Copied from [scanResult].
  ScanResultProvider call(String scanId) {
    return ScanResultProvider(scanId);
  }

  @override
  ScanResultProvider getProviderOverride(
    covariant ScanResultProvider provider,
  ) {
    return call(provider.scanId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'scanResultProvider';
}

/// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
/// only — the fetch lives in the repository (§4.1).
///
/// Copied from [scanResult].
class ScanResultProvider extends AutoDisposeFutureProvider<ScanResult> {
  /// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
  /// only — the fetch lives in the repository (§4.1).
  ///
  /// Copied from [scanResult].
  ScanResultProvider(String scanId)
    : this._internal(
        (ref) => scanResult(ref as ScanResultRef, scanId),
        from: scanResultProvider,
        name: r'scanResultProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$scanResultHash,
        dependencies: ScanResultFamily._dependencies,
        allTransitiveDependencies: ScanResultFamily._allTransitiveDependencies,
        scanId: scanId,
      );

  ScanResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scanId,
  }) : super.internal();

  final String scanId;

  @override
  Override overrideWith(
    FutureOr<ScanResult> Function(ScanResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ScanResultProvider._internal(
        (ref) => create(ref as ScanResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scanId: scanId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ScanResult> createElement() {
    return _ScanResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScanResultProvider && other.scanId == scanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScanResultRef on AutoDisposeFutureProviderRef<ScanResult> {
  /// The parameter `scanId` of this provider.
  String get scanId;
}

class _ScanResultProviderElement
    extends AutoDisposeFutureProviderElement<ScanResult>
    with ScanResultRef {
  _ScanResultProviderElement(super.provider);

  @override
  String get scanId => (origin as ScanResultProvider).scanId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
