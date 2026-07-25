// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_capture_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanCaptureControllerHash() =>
    r'822d92dd7d1aed5e687f6827a53d27180af4a3ad';

/// Orchestrates capture → submit → (poll) → result. Talks only to the
/// repository, never the network directly (docs/flutter_app_architecture.md
/// §4.1). The widget calls these methods and renders [state]; it holds no
/// business logic itself.
///
/// Copied from [ScanCaptureController].
@ProviderFor(ScanCaptureController)
final scanCaptureControllerProvider =
    AutoDisposeNotifierProvider<
      ScanCaptureController,
      ScanCaptureState
    >.internal(
      ScanCaptureController.new,
      name: r'scanCaptureControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scanCaptureControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScanCaptureController = AutoDisposeNotifier<ScanCaptureState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
