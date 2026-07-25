import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/scan_result.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../data/api_scan_repository.dart';
import '../data/fake_scan_repository.dart';
import '../data/scan_repository.dart';

part 'scan_result_provider.g.dart';

/// Binding for the [ScanRepository]. Binds the real Dio-backed repo by default;
/// falls back to the fake with `--dart-define=USE_FAKES=true`.
@riverpod
ScanRepository scanRepository(ScanRepositoryRef ref) => ApiConfig.useFakes
    ? FakeScanRepository()
    : ApiScanRepository(ref.watch(dioProvider));

/// Client-side cache populated by [ScanCaptureController] after a successful
/// scan so [scanResultProvider] returns the result without a network round-trip.
final scanResultCache = <String, ScanResult>{};

/// Fetches the [ScanResult] for a given `scanId` (family provider). Returns
/// the cached result immediately if available, otherwise falls back to GET.
@riverpod
Future<ScanResult> scanResult(ScanResultRef ref, String scanId) {
  final cached = scanResultCache[scanId];
  if (cached != null) return Future.value(cached);
  return ref.watch(scanRepositoryProvider).getScanResult(scanId);
}
