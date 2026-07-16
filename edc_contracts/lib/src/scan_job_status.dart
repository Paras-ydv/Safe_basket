import 'scan_result.dart';

/// Lifecycle of an asynchronous image-scan job: the backend wraps its
/// synchronous OCR scan behind a job the client polls.
enum ScanJobState { pending, done, failed }

class ScanJobStatus {
  const ScanJobStatus({required this.state, this.result, this.error});

  final ScanJobState state;
  final ScanResult? result;
  final String? error;

  bool get isDone => state == ScanJobState.done;
  bool get isFailed => state == ScanJobState.failed;

  factory ScanJobStatus.fromJson(Map<String, dynamic> json) => ScanJobStatus(
    state: switch (json['status'] as String?) {
      'done' => ScanJobState.done,
      'failed' => ScanJobState.failed,
      _ => ScanJobState.pending,
    },
    result: json['result'] == null
        ? null
        : ScanResult.fromJson(json['result'] as Map<String, dynamic>),
    error: json['error'] as String?,
  );

  Map<String, Object?> toJson() => {
    'status': switch (state) {
      ScanJobState.done => 'done',
      ScanJobState.failed => 'failed',
      ScanJobState.pending => 'pending',
    },
    'result': result?.toJson(),
    'error': error,
  };
}
