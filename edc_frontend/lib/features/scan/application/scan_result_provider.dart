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

/// Fetches the [ScanResult] for a given `scanId` (family provider). Orchestration
/// only — the fetch lives in the repository (§4.1).
@riverpod
Future<ScanResult> scanResult(ScanResultRef ref, String scanId) {
  return ref.watch(scanRepositoryProvider).getScanResult(scanId);
}
