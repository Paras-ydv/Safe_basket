import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../application/scan_capture_controller.dart';

/// Manual Entry screen (docs/flutter_app_architecture.md §5.2) — a simple
/// form so a user can look up a product or chemical by free text when a
/// barcode/label scan isn't possible.
///
/// This screen only captures input and renders the state produced by
/// [scanCaptureControllerProvider]; the actual lookup/matching happens on
/// the backend (§4.1). It lives outside the bottom-nav shell, so it owns
/// its own [Scaffold]/[AppBar].
class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild so the "Check" button's enabled state stays in sync with the
    // field's contents.
    setState(() {});
  }

  void _submit(bool busy) {
    if (busy) return;
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    ref.read(scanCaptureControllerProvider.notifier).scanManual(query);
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
    final busy =
        captureState is ScanSubmitting || captureState is ScanProcessing;
    final canSubmit = _controller.text.trim().isNotEmpty && !busy;

    return Scaffold(
      appBar: AppBar(title: const Text('Manual Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HelperText(),
            const SizedBox(height: 20),
            _QueryField(
              controller: _controller,
              enabled: !busy,
              onSubmitted: () => _submit(busy),
            ),
            const SizedBox(height: 24),
            _CheckButton(
              enabled: canSubmit,
              busy: busy,
              onPressed: () => _submit(busy),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brief instructional line above the input field.
class _HelperText extends StatelessWidget {
  const _HelperText();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Enter a product name or chemical to check its risk.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Free-text input for the product/chemical query. Submitting from the
/// keyboard triggers the same action as the "Check" button.
class _QueryField extends StatelessWidget {
  const _QueryField({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        labelText: 'Product or chemical',
        hintText: 'e.g. BPA, plastic water bottle',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => onSubmitted(),
    );
  }
}

/// Primary submit button. Shows a spinner and disables itself while a
/// submission is in flight.
class _CheckButton extends StatelessWidget {
  const _CheckButton({
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
          : const Text('Check'),
    );
  }
}
