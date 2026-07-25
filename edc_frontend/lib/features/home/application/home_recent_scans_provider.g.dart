// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_recent_scans_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRecentScansHash() => r'402a9314563d40b0cedd7d58d46e11c5d39134de';

/// UI state for the Home "Recent Scans" teaser. Orchestration only — the actual
/// fetch lives in the history feature's repository
/// (docs/flutter_app_architecture.md §4.1). Home depends on `history`, which
/// owns the scan-history data.
///
/// Copied from [HomeRecentScans].
@ProviderFor(HomeRecentScans)
final homeRecentScansProvider =
    AutoDisposeAsyncNotifierProvider<
      HomeRecentScans,
      List<ScanResult>
    >.internal(
      HomeRecentScans.new,
      name: r'homeRecentScansProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeRecentScansHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeRecentScans = AutoDisposeAsyncNotifier<List<ScanResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
