// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsRepositoryHash() =>
    r'cf0a73c0a84885619dca0a972c0b68752d5e85a9';

/// Binding for the [NotificationsRepository]. Real Dio-backed repo by default;
/// falls back to the fake with `--dart-define=USE_FAKES=true`.
///
/// Copied from [notificationsRepository].
@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider =
    AutoDisposeProvider<NotificationsRepository>.internal(
      notificationsRepository,
      name: r'notificationsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsRepositoryRef =
    AutoDisposeProviderRef<NotificationsRepository>;
String _$notificationsListHash() => r'd61ff1bb2494a294af162a4914e33feb1e16a5e0';

/// The user's notification inbox, newest first.
///
/// Copied from [notificationsList].
@ProviderFor(notificationsList)
final notificationsListProvider =
    AutoDisposeFutureProvider<List<AppNotification>>.internal(
      notificationsList,
      name: r'notificationsListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsListRef =
    AutoDisposeFutureProviderRef<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
