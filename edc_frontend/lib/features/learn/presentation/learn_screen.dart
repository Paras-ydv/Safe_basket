import 'package:flutter/material.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/theme/risk_colors.dart';

/// Learn tab — static educational content about endocrine-disrupting
/// chemicals (EDCs) (docs/flutter_app_architecture.md §5 "Learn").
///
/// Purely presentational: there is no backend call, provider, or business
/// logic here. The bottom nav is supplied by the app shell
/// (StatefulShellRoute), not this screen.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionCard(
            title: 'What are EDCs?',
            body:
                'Endocrine-disrupting chemicals (EDCs) are substances that '
                'can interfere with the body\'s hormone systems. They occur '
                'naturally in some foods, but many are man-made and found in '
                'everyday consumer products.',
          ),
          SizedBox(height: 12),
          _SectionCard(
            title: "Where they're found",
            body:
                'Common sources include cosmetics and personal care '
                'products, plastics and food packaging, household cleaners, '
                'and drinking water. Exposure often comes from a mix of '
                'small amounts across many everyday products.',
          ),
          SizedBox(height: 12),
          _SectionCard(
            title: 'Why it matters',
            body:
                'Hormones help regulate many body processes. At a general '
                'level, repeated exposure to certain chemicals may interact '
                'with hormone signaling over time. This app provides general '
                'information only — it does not diagnose or predict '
                'individual health outcomes.',
          ),
          SizedBox(height: 12),
          _SectionCard(
            title: 'How this app helps',
            body:
                'Capture a product label or barcode, and our backend '
                'analyzes the ingredients to identify chemicals of concern. '
                'You then see a clear, easy-to-understand risk rating for '
                'that product.',
          ),
          SizedBox(height: 12),
          _SectionCard(
            title: 'Reducing exposure',
            body:
                '• Prefer products with simpler ingredient lists.\n'
                '• Store food in glass or stainless steel rather than '
                'plastic when possible.\n'
                '• Air out new products before use.\n'
                '• Check labels for fragrance-free or unscented options.\n'
                '• Wash hands after handling receipts or plastics.',
          ),
          SizedBox(height: 20),
          _RiskLevelsLegend(),
          SizedBox(height: 20),
          _Disclaimer(),
        ],
      ),
    );
  }
}

/// A single collapsible educational topic.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared risk vocabulary legend — mirrors [RiskLevel] and resolves colors
/// via the theme's `RiskColors` extension, never hardcoded.
class _RiskLevelsLegend extends StatelessWidget {
  const _RiskLevelsLegend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk levels',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            for (final level in RiskLevel.values) _RiskLevelRow(level: level),
          ],
        ),
      ),
    );
  }
}

/// One row of the legend: a color swatch plus the level's label.
class _RiskLevelRow extends StatelessWidget {
  const _RiskLevelRow({required this.level});

  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.riskColors.colorFor(level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(level.label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// General-information disclaimer shown at the bottom of the screen.
class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'This content is general information only and is not medical advice. '
      'Consult a qualified professional for guidance specific to you.',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
