import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/risk_level.dart';
import '../../../core/theme/risk_colors.dart';
import '../application/chemical_detail_provider.dart';
import '../domain/chemical_detail.dart';
import '../domain/exposure_route.dart';

/// Chemical Details — `/chemical/:id` (docs/flutter_app_architecture.md §5.5).
///
/// Renders the backend/knowledge-base record for a single chemical: name,
/// risk badge, class, health effects, exposure routes and regulatory status.
/// This screen authors NO clinical content of its own — all text is rendered
/// verbatim from [ChemicalDetail]; risk is only colored via the theme, never
/// computed.
class ChemicalDetailScreen extends ConsumerWidget {
  const ChemicalDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(chemicalDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Chemical')),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: error.toString()),
        data: (detail) => _ChemicalDetailBody(detail: detail),
      ),
    );
  }
}

/// Scrollable body laying out every section of a loaded [ChemicalDetail].
class _ChemicalDetailBody extends StatelessWidget {
  const _ChemicalDetailBody({required this.detail});

  final ChemicalDetail detail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChemicalHeader(detail: detail),
          const SizedBox(height: 24),
          _Section(
            title: 'Chemical Class',
            child: Text(detail.chemicalClass),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Health Effects',
            child: _HealthEffectsList(effects: detail.healthEffects),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Exposure Routes',
            child: _ExposureRoutesRow(routes: detail.exposureRoutes),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Regulatory Status',
            child: Text(detail.regulatoryStatus),
          ),
        ],
      ),
    );
  }
}

/// Chemical name with a backend-colored risk badge beside it.
class _ChemicalHeader extends StatelessWidget {
  const _ChemicalHeader({required this.detail});

  final ChemicalDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            detail.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _RiskBadge(risk: detail.risk),
      ],
    );
  }
}

/// Colored risk badge. Color resolved from the theme's [RiskColors]
/// extension — never hardcoded and never computed here.
class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.risk});

  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final color = context.riskColors.colorFor(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        risk.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Labelled section wrapper shared by every body section.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Bulleted list of backend-provided health effects, rendered verbatim.
class _HealthEffectsList extends StatelessWidget {
  const _HealthEffectsList({required this.effects});

  final List<String> effects;

  @override
  Widget build(BuildContext context) {
    if (effects.isEmpty) {
      return const Text('No health effects reported.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final effect in effects)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(effect)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Wrapped row of exposure-route icon + label pairs.
class _ExposureRoutesRow extends StatelessWidget {
  const _ExposureRoutesRow({required this.routes});

  final List<ExposureRoute> routes;

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const Text('No exposure routes reported.');
    }
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        for (final route in routes) _ExposureRouteChip(route: route),
      ],
    );
  }
}

/// A single exposure route rendered as an icon (presentation choice, mapped
/// locally) plus the backend-provided [ExposureRoute.label].
class _ExposureRouteChip extends StatelessWidget {
  const _ExposureRouteChip({required this.route});

  final ExposureRoute route;

  IconData get _icon => switch (route) {
    ExposureRoute.dermal => Icons.back_hand_outlined,
    ExposureRoute.ingestion => Icons.restaurant_outlined,
    ExposureRoute.inhalation => Icons.air,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(route.label),
      ],
    );
  }
}

/// Friendly error state for a failed chemical-detail fetch.
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
              "Couldn't load this chemical",
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
