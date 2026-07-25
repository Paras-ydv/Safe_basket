import '../../../core/models/scan_result.dart';

/// Lifecycle of an asynchronous OCR job (docs/flutter_app_architecture.md §3):
/// `POST /scan/image` returns a job that is polled until it is done or failed.
enum ScanJobState { pending, done, failed }

/// One poll response for an async image-scan job.
class ScanJobStatus {
  const ScanJobStatus({required this.state, this.result, this.error});

  final ScanJobState state;

  /// Present only when [state] is [ScanJobState.done].
  final ScanResult? result;

  /// Present only when [state] is [ScanJobState.failed].
  final String? error;

  bool get isDone => state == ScanJobState.done;
  bool get isFailed => state == ScanJobState.failed;
}
