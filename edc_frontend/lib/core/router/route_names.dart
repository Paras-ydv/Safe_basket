/// Named routes for GoRouter. Navigate with `context.goNamed(RouteNames.x)`
/// rather than stringly-typed paths.
abstract final class RouteNames {
  static const home = 'home';
  static const history = 'history';
  static const water = 'water';
  static const learn = 'learn';
  static const profile = 'profile';

  /// Scan Options hub (§5.2) — target of the Home "Start Scanning" CTA.
  static const scan = 'scan';

  // Capture modalities routed from Scan Options. Scanning/manual/water capture
  // screens are not built yet — these currently resolve to placeholders.
  static const scanBarcode = 'scanBarcode';
  static const scanLabel = 'scanLabel';
  static const scanManual = 'scanManual';
  static const scanWater = 'scanWater';

  /// Result screen (§5.4). Takes a `scanId` path parameter.
  static const scanResult = 'scanResult';

  /// Chemical Details (§5.5). Takes an `id` path parameter.
  static const chemicalDetail = 'chemicalDetail';

  /// Safer alternatives list (§3) for a chemical. Placeholder for now.
  static const chemicalAlternatives = 'chemicalAlternatives';

  /// In-app notification inbox (§2), opened from the Home bell.
  static const notifications = 'notifications';
}
