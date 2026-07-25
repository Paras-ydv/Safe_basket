import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../enums/risk_level.dart';
import '../models/scan_result.dart';

/// Renders a [ScanResult] into a shareable PDF report on-device (client-rendered
/// export per docs/flutter_app_architecture.md §3). Pure formatting of
/// backend-provided data — it computes no risk.
abstract final class ScanReportBuilder {
  static Future<Uint8List> build(ScanResult result) async {
    final doc = pw.Document();

    PdfColor riskColor(RiskLevel level) => switch (level) {
      RiskLevel.low => PdfColors.green700,
      RiskLevel.moderate => PdfColors.amber700,
      RiskLevel.high => PdfColors.orange800,
      RiskLevel.veryHigh => PdfColors.red800,
    };

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'EDC Scan Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            result.productName,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          if (result.productMeta != null)
            pw.Text(
              result.productMeta!,
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Scanned: ${_formatDate(result.scannedAt)}',
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: riskColor(result.overallRisk),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'Overall risk: ${result.overallRisk.label}',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          if (result.detectedChemicals.isNotEmpty) ...[
            pw.Text(
              'Detected chemicals',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Chemical', 'Risk'],
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              data: [
                for (final chem in result.detectedChemicals)
                  [chem.name, chem.risk.label],
              ],
            ),
          ],
          if (result.disclaimer != null) ...[
            pw.SizedBox(height: 24),
            pw.Text(
              result.disclaimer!,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
