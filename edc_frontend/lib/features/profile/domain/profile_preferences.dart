/// On-device user preferences (docs/flutter_app_architecture.md §2 — local
/// persistence is ours). Currently held in memory only; wire to
/// `shared_preferences` for durable storage later.
class ProfilePreferences {
  const ProfilePreferences({
    this.highRiskAlerts = true,
    this.weeklyDigest = false,
    this.productRecalls = true,
  });

  /// Notify when a scan returns a high / very-high overall risk.
  final bool highRiskAlerts;

  /// Send a weekly summary of exposure trends.
  final bool weeklyDigest;

  /// Alert on recalls affecting previously scanned products.
  final bool productRecalls;

  ProfilePreferences copyWith({
    bool? highRiskAlerts,
    bool? weeklyDigest,
    bool? productRecalls,
  }) {
    return ProfilePreferences(
      highRiskAlerts: highRiskAlerts ?? this.highRiskAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      productRecalls: productRecalls ?? this.productRecalls,
    );
  }
}
