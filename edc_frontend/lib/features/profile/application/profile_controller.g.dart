// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileControllerHash() => r'19e5fcd1e16ec772df3efa5067b5549ecd076229';

/// Holds the user's on-device preferences and persists them via
/// `shared_preferences` (docs/flutter_app_architecture.md §2 — local
/// persistence is ours). Preference logic stays out of the UI (§4.1).
///
/// Copied from [ProfileController].
@ProviderFor(ProfileController)
final profileControllerProvider =
    AutoDisposeNotifierProvider<ProfileController, ProfilePreferences>.internal(
      ProfileController.new,
      name: r'profileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileController = AutoDisposeNotifier<ProfilePreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
