import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/models/detected_chemical.dart';
import '../../../core/models/scan_result.dart';
import '../../../core/report/scan_report_builder.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/risk_colors.dart';
import '../application/scan_result_provider.dart';

/// Result screen (docs/flutter_app_architecture.md §5.4) — shows the backend's
/// verdict for a single scan: overall risk banner, detected chemicals and a
/// verbatim disclaimer.
///
/// Presentation only: it watches [scanResultProvider] and renders the
/// backend-supplied `RiskLevel` values via the theme's `RiskColors` — it never
/// computes or overrides risk itself. This route lives outside the app shell,
/// so no `BottomNavigationBar` is added here.
class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({super.key, required this.scanId});

  final String scanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(scanResultProvider(scanId));
    final scan = result.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          if (scan != null)
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Export report (PDF)',
              onPressed: () => _exportPdf(scan),
            ),
        ],
      ),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: error.toString()),
        data: (scan) => _ResultBody(scan: scan),
      ),
    );
  }

  /// Renders the report on-device and hands it to the system share sheet
  /// (client-rendered export, §3). PDF construction lives in the report
  /// builder, not the widget.
  Future<void> _exportPdf(ScanResult scan) async {
    final bytes = await ScanReportBuilder.build(scan);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'edc-scan-${scan.scanId}.pdf',
    );
  }
}

/// Scrollable body rendering a loaded [ScanResult].
class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.scan});

  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProductHeader(scan: scan),
          const SizedBox(height: 16),
          _OverallRiskBanner(risk: scan.overallRisk),
          const SizedBox(height: 24),
          Text(
            'Detected Chemicals',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (scan.detectedChemicals.isEmpty)
            const _NoChemicalsState()
          else
            for (final chemical in scan.detectedChemicals)
              _ChemicalTile(chemical: chemical),
          if (scan.disclaimer != null) ...[
            const SizedBox(height: 24),
            _DisclaimerNote(text: scan.disclaimer!),
          ],
        ],
      ),
    );
  }
}

/// Product name, optional metadata (batch/size) and the formatted scan date.
class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.scan});

  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          scan.productName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (scan.productMeta != null) ...[
          const SizedBox(height: 4),
          Text(
            scan.productMeta!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Scanned ${_formatDate(scan.scannedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Prominent overall-risk banner. Color and label are entirely
/// backend/theme-driven — no risk computation happens here.
class _OverallRiskBanner extends StatelessWidget {
  const _OverallRiskBanner({required this.risk});

  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final color = context.riskColors.colorFor(risk);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.shield_outlined, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            'Overall Risk',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            risk.label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single detected-chemical row with a risk chip and two navigation actions.
class _ChemicalTile extends StatelessWidget {
  const _ChemicalTile({required this.chemical});

  final DetectedChemical chemical;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    chemical.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _RiskChip(risk: chemical.risk),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => context.goNamed(
                    RouteNames.chemicalDetail,
                    pathParameters: {'id': chemical.id},
                  ),
                  child: const Text('View Details'),
                ),
                TextButton(
                  onPressed: () => context.goNamed(
                    RouteNames.chemicalAlternatives,
                    pathParameters: {'id': chemical.id},
                  ),
                  child: const Text('Safer Alternatives'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small colored chip showing a backend-provided risk level. The color comes
/// from the theme's [RiskColors] extension — never computed here.
class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.risk});

  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final color = context.riskColors.colorFor(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        risk.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Shown when the backend reports no detected chemicals for this scan.
class _NoChemicalsState extends StatelessWidget {
  const _NoChemicalsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'No chemicals were detected for this product.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// De-emphasized, verbatim disclaimer text supplied by the backend.
class _DisclaimerNote extends StatelessWidget {
  const _DisclaimerNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// Friendly error state for a failed scan-result fetch.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              "Couldn't load this result",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny inline date formatter so we don't pull in a dependency (CLAUDE.md
/// forbids adding packages).
String _formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}
