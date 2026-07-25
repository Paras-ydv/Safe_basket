import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'scan_result_provider.dart';

part 'scan_capture_controller.g.dart';

/// UI state for an in-progress capture. Sealed so the screen can exhaustively
/// render each phase.
sealed class ScanCaptureState {
  const ScanCaptureState();
}

/// Nothing submitted yet — the camera is live and waiting.
class ScanIdle extends ScanCaptureState {
  const ScanIdle();
}

/// A barcode value / image is being uploaded (short, synchronous phase).
class ScanSubmitting extends ScanCaptureState {
  const ScanSubmitting();
}

/// An async OCR job is being polled — this is the longer wait (§5.3).
class ScanProcessing extends ScanCaptureState {
  const ScanProcessing();
}

/// The backend returned a result; navigate to `/scan/result/:scanId`.
class ScanSuccess extends ScanCaptureState {
  const ScanSuccess(this.scanId);
  final String scanId;
}

/// Something went wrong (permission, network, timeout, failed job).
class ScanFailure extends ScanCaptureState {
  const ScanFailure(this.message);
  final String message;
}

/// Orchestrates capture → submit → (poll) → result. Talks only to the
/// repository, never the network directly (docs/flutter_app_architecture.md
/// §4.1). The widget calls these methods and renders [state]; it holds no
/// business logic itself.
@riverpod
class ScanCaptureController extends _$ScanCaptureController {
  bool _cancelled = false;

  @override
  ScanCaptureState build() => const ScanIdle();

  bool get _busy => state is ScanSubmitting || state is ScanProcessing;

  /// Synchronous barcode lookup (`POST /scan/barcode`).
  Future<void> scanBarcode({
    required String value,
    required String symbology,
  }) async {
    if (_busy) return; // ignore repeat detections while working
    state = const ScanSubmitting();
    try {
      final result = await ref
          .read(scanRepositoryProvider)
          .submitBarcode(value: value, symbology: symbology);
      state = ScanSuccess(result.scanId);
    } catch (_) {
      state = const ScanFailure(
        'Could not look up that barcode. Check your connection and try again.',
      );
    }
  }

  /// Water source check (`POST /scan/water`).
  Future<void> scanWater({
    required String sourceType,
    required String location,
  }) async {
    if (_busy) return;
    state = const ScanSubmitting();
    try {
      final result = await ref
          .read(scanRepositoryProvider)
          .submitWater(sourceType: sourceType, location: location);
      state = ScanSuccess(result.scanId);
    } catch (_) {
      state = const ScanFailure(
        'Could not check that water source. Check your connection and try again.',
      );
    }
  }

  /// Manual product / chemical entry (`POST /scan/manual`).
  Future<void> scanManual(String query) async {
    if (_busy) return;
    state = const ScanSubmitting();
    try {
      final result = await ref.read(scanRepositoryProvider).submitManual(query);
      state = ScanSuccess(result.scanId);
    } catch (_) {
      state = const ScanFailure(
        'Could not look that up. Check your connection and try again.',
      );
    }
  }

  /// Asynchronous label OCR: submit the image, then poll until done/failed
  /// (§5.3). Pass the captured/picked image path.
  Future<void> captureLabel(String imagePath) async {
    if (_busy) return;
    _cancelled = false;
    state = const ScanSubmitting();
    try {
      final repo = ref.read(scanRepositoryProvider);
      final jobId = await repo.submitImageScan(imagePath);
      if (_cancelled) return;

      state = const ScanProcessing();
      const maxAttempts = 20;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        if (_cancelled) return;
        final status = await repo.pollImageScan(jobId);
        if (_cancelled) return;
        if (status.isDone && status.result != null) {
          state = ScanSuccess(status.result!.scanId);
          return;
        }
        if (status.isFailed) {
          state = ScanFailure(
            status.error ?? 'The scan failed. Please try again.',
          );
          return;
        }
        // Pace the polling for a real backend (the fake also delays internally).
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
      state = const ScanFailure('The scan timed out. Please try again.');
    } catch (_) {
      state = const ScanFailure(
        'Could not process that image. Check your connection and try again.',
      );
    }
  }

  /// Cancel an in-flight capture and return the camera to idle.
  void cancel() {
    _cancelled = true;
    state = const ScanIdle();
  }

  /// Reset after an error to resume scanning.
  void reset() {
    _cancelled = false;
    state = const ScanIdle();
  }
}
