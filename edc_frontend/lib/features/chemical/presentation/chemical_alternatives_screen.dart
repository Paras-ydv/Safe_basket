import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/risk_colors.dart';
import '../application/chemical_detail_provider.dart';
import '../domain/alternative.dart';

/// Safer Alternatives — `GET /chemicals/{id}/alternatives`
/// (docs/flutter_app_architecture.md §3). Lives outside the bottom-nav shell.
///
/// Renders the backend-supplied list of safer alternatives for a chemical.
/// This screen never decides what is "safer" — it only renders the list and
/// maps the backend-provided [Alternative.risk] to a color via the theme.
class ChemicalAlternativesScreen extends ConsumerWidget {
  const ChemicalAlternativesScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alternativesState = ref.watch(chemicalAlternativesProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Safer Alternatives')),
      body: alternativesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: error.toString()),
        data: (alternatives) {
          if (alternatives.isEmpty) {
            return const _EmptyState();
          }
          return _AlternativesList(alternatives: alternatives);
        },
      ),
    );
  }
}

/// Scrollable list of backend-provided safer alternatives.
class _AlternativesList extends StatelessWidget {
  const _AlternativesList({required this.alternatives});

  final List<Alternative> alternatives;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alternatives.length,
      itemBuilder: (context, index) =>
          _AlternativeTile(alternative: alternatives[index]),
    );
  }
}

/// A single alternative row: name, risk chip, and optional note.
class _AlternativeTile extends StatelessWidget {
  const _AlternativeTile({required this.alternative});

  final Alternative alternative;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.goNamed(
          RouteNames.chemicalDetail,
          pathParameters: {'id': alternative.id},
        ),
        title: Text(alternative.name),
        subtitle: alternative.note != null ? Text(alternative.note!) : null,
        trailing: _RiskChip(risk: alternative.risk),
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

/// Shown when the backend returns no alternatives for this chemical.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text('No alternatives found', style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

/// Friendly error state for a failed alternatives fetch.
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
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              "Couldn't load safer alternatives",
              style: theme.textTheme.titleSmall,
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
