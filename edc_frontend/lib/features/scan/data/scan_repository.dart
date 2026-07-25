import '../../../core/models/scan_result.dart';
import '../domain/scan_job.dart';

/// Network boundary for the scan feature (docs/flutter_app_architecture.md
/// §4.1). Returns domain models, never raw JSON. Backed by
/// [FakeScanRepository] until the backend `/scan/*` endpoints are ready.
abstract interface class ScanRepository {
  /// Fetch a single scan outcome by id (backend `GET`/cache).
  Future<ScanResult> getScanResult(String scanId);

  /// Synchronous barcode lookup (`POST /scan/barcode`). The client decodes the
  /// symbology on-device and sends the value.
  Future<ScanResult> submitBarcode({
    required String value,
    required String symbology,
  });

  /// Submit a label/ingredients image for asynchronous OCR (`POST /scan/image`).
  /// Returns a `jobId` to poll — the client never runs OCR locally (§5.3).
  Future<String> submitImageScan(String imagePath);

  /// Poll an async image-scan job (`GET /scan/image/{jobId}`).
  Future<ScanJobStatus> pollImageScan(String jobId);

  /// Water source check (`POST /scan/water`) — environmental assessment.
  Future<ScanResult> submitWater({
    required String sourceType,
    required String location,
  });

  /// Manual product / chemical entry (`POST /scan/manual`).
  Future<ScanResult> submitManual(String query);
}
