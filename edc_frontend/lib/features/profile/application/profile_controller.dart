import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/shared_preferences_provider.dart';
import '../domain/profile_preferences.dart';

part 'profile_controller.g.dart';

/// Holds the user's on-device preferences and persists them via
/// `shared_preferences` (docs/flutter_app_architecture.md §2 — local
/// persistence is ours). Preference logic stays out of the UI (§4.1).
@riverpod
class ProfileController extends _$ProfileController {
  static const _kHighRiskAlerts = 'pref_high_risk_alerts';
  static const _kWeeklyDigest = 'pref_weekly_digest';
  static const _kProductRecalls = 'pref_product_recalls';

  @override
  ProfilePreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    const defaults = ProfilePreferences();
    return ProfilePreferences(
      highRiskAlerts: prefs.getBool(_kHighRiskAlerts) ?? defaults.highRiskAlerts,
      weeklyDigest: prefs.getBool(_kWeeklyDigest) ?? defaults.weeklyDigest,
      productRecalls:
          prefs.getBool(_kProductRecalls) ?? defaults.productRecalls,
    );
  }

  void setHighRiskAlerts(bool value) {
    ref.read(sharedPreferencesProvider).setBool(_kHighRiskAlerts, value);
    state = state.copyWith(highRiskAlerts: value);
  }

  void setWeeklyDigest(bool value) {
    ref.read(sharedPreferencesProvider).setBool(_kWeeklyDigest, value);
    state = state.copyWith(weeklyDigest: value);
  }

  void setProductRecalls(bool value) {
    ref.read(sharedPreferencesProvider).setBool(_kProductRecalls, value);
    state = state.copyWith(productRecalls: value);
  }
}
