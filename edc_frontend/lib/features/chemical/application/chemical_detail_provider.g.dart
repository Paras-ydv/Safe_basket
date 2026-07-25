// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chemical_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chemicalRepositoryHash() =>
    r'18c829cb7fc55dde516174b39314c204a2f333df';

/// Binding for the [ChemicalRepository]. Binds the real Dio-backed repo by
/// default; falls back to the fake with `--dart-define=USE_FAKES=true`.
///
/// Copied from [chemicalRepository].
@ProviderFor(chemicalRepository)
final chemicalRepositoryProvider =
    AutoDisposeProvider<ChemicalRepository>.internal(
      chemicalRepository,
      name: r'chemicalRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chemicalRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChemicalRepositoryRef = AutoDisposeProviderRef<ChemicalRepository>;
String _$chemicalDetailHash() => r'0dd444c39d5d734d6fcd97049b19b74438a236f5';

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

/// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
/// fetch lives in the repository (§4.1).
///
/// Copied from [chemicalDetail].
@ProviderFor(chemicalDetail)
const chemicalDetailProvider = ChemicalDetailFamily();

/// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
/// fetch lives in the repository (§4.1).
///
/// Copied from [chemicalDetail].
class ChemicalDetailFamily extends Family<AsyncValue<ChemicalDetail>> {
  /// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
  /// fetch lives in the repository (§4.1).
  ///
  /// Copied from [chemicalDetail].
  const ChemicalDetailFamily();

  /// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
  /// fetch lives in the repository (§4.1).
  ///
  /// Copied from [chemicalDetail].
  ChemicalDetailProvider call(String id) {
    return ChemicalDetailProvider(id);
  }

  @override
  ChemicalDetailProvider getProviderOverride(
    covariant ChemicalDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chemicalDetailProvider';
}

/// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
/// fetch lives in the repository (§4.1).
///
/// Copied from [chemicalDetail].
class ChemicalDetailProvider extends AutoDisposeFutureProvider<ChemicalDetail> {
  /// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
  /// fetch lives in the repository (§4.1).
  ///
  /// Copied from [chemicalDetail].
  ChemicalDetailProvider(String id)
    : this._internal(
        (ref) => chemicalDetail(ref as ChemicalDetailRef, id),
        from: chemicalDetailProvider,
        name: r'chemicalDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chemicalDetailHash,
        dependencies: ChemicalDetailFamily._dependencies,
        allTransitiveDependencies:
            ChemicalDetailFamily._allTransitiveDependencies,
        id: id,
      );

  ChemicalDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<ChemicalDetail> Function(ChemicalDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChemicalDetailProvider._internal(
        (ref) => create(ref as ChemicalDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChemicalDetail> createElement() {
    return _ChemicalDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChemicalDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChemicalDetailRef on AutoDisposeFutureProviderRef<ChemicalDetail> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ChemicalDetailProviderElement
    extends AutoDisposeFutureProviderElement<ChemicalDetail>
    with ChemicalDetailRef {
  _ChemicalDetailProviderElement(super.provider);

  @override
  String get id => (origin as ChemicalDetailProvider).id;
}

String _$chemicalAlternativesHash() =>
    r'b458c8f69827a8326ebc11925a3e72e5455e46f3';

/// Safer alternatives for a chemical (family provider). Orchestration only.
///
/// Copied from [chemicalAlternatives].
@ProviderFor(chemicalAlternatives)
const chemicalAlternativesProvider = ChemicalAlternativesFamily();

/// Safer alternatives for a chemical (family provider). Orchestration only.
///
/// Copied from [chemicalAlternatives].
class ChemicalAlternativesFamily extends Family<AsyncValue<List<Alternative>>> {
  /// Safer alternatives for a chemical (family provider). Orchestration only.
  ///
  /// Copied from [chemicalAlternatives].
  const ChemicalAlternativesFamily();

  /// Safer alternatives for a chemical (family provider). Orchestration only.
  ///
  /// Copied from [chemicalAlternatives].
  ChemicalAlternativesProvider call(String id) {
    return ChemicalAlternativesProvider(id);
  }

  @override
  ChemicalAlternativesProvider getProviderOverride(
    covariant ChemicalAlternativesProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chemicalAlternativesProvider';
}

/// Safer alternatives for a chemical (family provider). Orchestration only.
///
/// Copied from [chemicalAlternatives].
class ChemicalAlternativesProvider
    extends AutoDisposeFutureProvider<List<Alternative>> {
  /// Safer alternatives for a chemical (family provider). Orchestration only.
  ///
  /// Copied from [chemicalAlternatives].
  ChemicalAlternativesProvider(String id)
    : this._internal(
        (ref) => chemicalAlternatives(ref as ChemicalAlternativesRef, id),
        from: chemicalAlternativesProvider,
        name: r'chemicalAlternativesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chemicalAlternativesHash,
        dependencies: ChemicalAlternativesFamily._dependencies,
        allTransitiveDependencies:
            ChemicalAlternativesFamily._allTransitiveDependencies,
        id: id,
      );

  ChemicalAlternativesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<List<Alternative>> Function(ChemicalAlternativesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChemicalAlternativesProvider._internal(
        (ref) => create(ref as ChemicalAlternativesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Alternative>> createElement() {
    return _ChemicalAlternativesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChemicalAlternativesProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChemicalAlternativesRef
    on AutoDisposeFutureProviderRef<List<Alternative>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ChemicalAlternativesProviderElement
    extends AutoDisposeFutureProviderElement<List<Alternative>>
    with ChemicalAlternativesRef {
  _ChemicalAlternativesProviderElement(super.provider);

  @override
  String get id => (origin as ChemicalAlternativesProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
