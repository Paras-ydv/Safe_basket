import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../application/scan_capture_controller.dart';

/// Water Source Check screen (docs/flutter_app_architecture.md §5 water
/// flow) — a short form that submits a water source for backend
/// environmental assessment.
///
/// Presentation only (§4.1): it captures the source type and location and
/// hands them to [ScanCaptureController]. It computes no risk itself and
/// only renders the state produced by the notifier. It lives outside the
/// bottom-nav shell, so it owns its own [Scaffold]/[AppBar].
class WaterCheckScreen extends ConsumerStatefulWidget {
  const WaterCheckScreen({super.key});

  @override
  ConsumerState<WaterCheckScreen> createState() => _WaterCheckScreenState();
}

class _WaterCheckScreenState extends ConsumerState<WaterCheckScreen> {
  late final TextEditingController _locationController;
  String? _sourceType;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _locationController.addListener(() {
      // Rebuild so the submit button's enabled state stays in sync with
      // the text field's contents.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _sourceType != null && _locationController.text.trim().isNotEmpty;

  void _onSourceTypeSelected(String sourceType) {
    setState(() => _sourceType = sourceType);
  }

  void _onSubmit() {
    final sourceType = _sourceType;
    if (sourceType == null) return;
    ref
        .read(scanCaptureControllerProvider.notifier)
        .scanWater(
          sourceType: sourceType,
          location: _locationController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScanCaptureState>(scanCaptureControllerProvider, (
      previous,
      next,
    ) {
      if (next is ScanSuccess) {
        context.goNamed(
          RouteNames.scanResult,
          pathParameters: {'scanId': next.scanId},
        );
      } else if (next is ScanFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final captureState = ref.watch(scanCaptureControllerProvider);
    final busy = captureState is ScanSubmitting || captureState is ScanProcessing;

    return Scaffold(
      appBar: AppBar(title: const Text('Water Source Check')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about your water source',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'We will check it for common contaminants and '
                'endocrine-disrupting chemicals.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _SourceTypeSelector(
                selected: _sourceType,
                onSelected: _onSourceTypeSelected,
              ),
              const SizedBox(height: 24),
              _LocationField(controller: _locationController),
              const SizedBox(height: 32),
              _SubmitButton(
                enabled: _canSubmit && !busy,
                busy: busy,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Required single-choice selector for the water source type, rendered as
/// wrapping [ChoiceChip]s.
class _SourceTypeSelector extends StatelessWidget {
  const _SourceTypeSelector({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  static const _options = <String>[
    'Tap water',
    'Bottled',
    'Well',
    'Borehole',
    'River / Stream',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Source type',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _options)
              ChoiceChip(
                label: Text(option),
                selected: selected == option,
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}

/// Free-text location field ("City or area").
class _LocationField extends StatelessWidget {
  const _LocationField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Location',
        hintText: 'City or area',
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Primary submit button, disabled until the form is valid and showing a
/// spinner while the submission is in flight.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Text('Check Water Source'),
    );
  }
}
