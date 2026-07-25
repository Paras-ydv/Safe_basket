import '../../../core/enums/risk_level.dart';
import '../../../core/models/detected_chemical.dart';
import '../../../core/models/scan_result.dart';
import '../domain/scan_job.dart';
import 'scan_repository.dart';

/// Canned [ScanRepository] used while the backend is not yet available
/// (docs/flutter_app_architecture.md §3 — develop against a fake repository).
///
/// Not `const`: it tracks poll attempts per job id so async OCR jobs report
/// `pending` a couple of times before completing, mimicking the real flow.
class FakeScanRepository implements ScanRepository {
  FakeScanRepository();

  /// How many times each async job has been polled so far.
  final Map<String, int> _pollCounts = {};

  ScanResult _sampleResult(String scanId) => ScanResult(
    scanId: scanId,
    productName: 'Sunrise Body Lotion',
    productMeta: 'Batch L2231 · 250 ml',
    scannedAt: DateTime.now().subtract(const Duration(hours: 2)),
    overallRisk: RiskLevel.high,
    detectedChemicals: const [
      DetectedChemical(id: 'bpa', name: 'Bisphenol A (BPA)', risk: RiskLevel.high),
      DetectedChemical(
        id: 'paraben-butyl',
        name: 'Butylparaben',
        risk: RiskLevel.moderate,
      ),
      DetectedChemical(
        id: 'phenoxyethanol',
        name: 'Phenoxyethanol',
        risk: RiskLevel.low,
      ),
    ],
    disclaimer:
        'Results are screening estimates based on label data and are not a '
        'substitute for laboratory confirmation.',
  );

  @override
  Future<ScanResult> getScanResult(String scanId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _sampleResult(scanId);
  }

  @override
  Future<ScanResult> submitBarcode({
    required String value,
    required String symbology,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _sampleResult('barcode-$value');
  }

  @override
  Future<ScanResult> submitWater({
    required String sourceType,
    required String location,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return ScanResult(
      scanId: 'water-${location.hashCode}',
      productName: '$sourceType — $location',
      productMeta: 'Water source sample',
      scannedAt: DateTime.now(),
      overallRisk: RiskLevel.moderate,
      detectedChemicals: const [
        DetectedChemical(id: 'atrazine', name: 'Atrazine', risk: RiskLevel.moderate),
        DetectedChemical(id: 'nitrate', name: 'Nitrate', risk: RiskLevel.low),
      ],
      disclaimer:
          'Environmental screening estimate based on reported source data; '
          'not a substitute for certified water-quality testing.',
    );
  }

  @override
  Future<ScanResult> submitManual(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _sampleResult('manual-${query.hashCode}').copyWith(
      productName: query,
    );
  }

  @override
  Future<String> submitImageScan(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final jobId = 'job-${DateTime.now().millisecondsSinceEpoch}';
    _pollCounts[jobId] = 0;
    return jobId;
  }

  @override
  Future<ScanJobStatus> pollImageScan(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final count = (_pollCounts[jobId] ?? 0) + 1;
    _pollCounts[jobId] = count;

    // Report pending for the first two polls, then complete.
    if (count < 3) {
      return const ScanJobStatus(state: ScanJobState.pending);
    }
    _pollCounts.remove(jobId);
    return ScanJobStatus(
      state: ScanJobState.done,
      result: _sampleResult('image-$jobId'),
    );
  }
}
