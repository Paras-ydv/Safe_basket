import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/route_names.dart';
import '../application/scan_capture_controller.dart';
import '../domain/scan_mode.dart';

/// Scanning screen (docs/flutter_app_architecture.md §5.3) — live camera
/// preview with a framing overlay, torch toggle, gallery pick, and scanning
/// tips. Renders both the barcode and label capture flows, parameterised by
/// [mode].
///
/// This screen only captures input and renders the state produced by
/// [scanCaptureControllerProvider]; it never runs OCR or chemical
/// recognition on-device — that is the backend's job (§4.1). It lives
/// outside the bottom-nav shell, so it owns its own [Scaffold]/[AppBar].
class ScanningScreen extends ConsumerStatefulWidget {
  const ScanningScreen({super.key, required this.mode});

  final ScanMode mode;

  @override
  ConsumerState<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends ConsumerState<ScanningScreen> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.mode != ScanMode.barcode) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;
      ref
          .read(scanCaptureControllerProvider.notifier)
          .scanBarcode(value: value, symbology: barcode.format.name);
      return;
    }
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
      }
    });

    final captureState = ref.watch(scanCaptureControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(widget.mode.title),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(controller: _controller, onDetect: _onDetect),
          ),
          const Positioned.fill(child: _FramingOverlay()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: _TipsLine(text: widget.mode.tip),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControlBar(controller: _controller, mode: widget.mode),
          ),
          if (captureState is! ScanIdle) _StatusOverlay(state: captureState, mode: widget.mode),
        ],
      ),
    );
  }
}

/// Dimmed surround with a clear rounded-rectangle cut-out and corner guides
/// so the user knows where to frame the barcode/label. Purely decorative —
/// no logic.
class _FramingOverlay extends StatelessWidget {
  const _FramingOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final frameWidth = constraints.maxWidth * 0.8;
          final frameHeight = frameWidth * 0.62;
          return Stack(
            alignment: Alignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: frameWidth,
                        height: frameHeight,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white70, width: 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A single legible line of scanning guidance, sitting on a scrim above the
/// bottom control bar.
class _TipsLine extends StatelessWidget {
  const _TipsLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

/// Bottom bar: torch toggle, gallery pick (stub), and — label mode only — a
/// shutter button to capture and submit the frame.
class _BottomControlBar extends ConsumerWidget {
  const _BottomControlBar({required this.controller, required this.mode});

  final MobileScannerController controller;
  final ScanMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TorchButton(controller: controller),
          if (mode == ScanMode.label) _ShutterButton(),
          _GalleryButton(controller: controller, mode: mode),
        ],
      ),
    );
  }
}

/// Torch on/off toggle. Reflects [MobileScannerController.value.torchState]
/// via a [ValueListenableBuilder] on the controller (a `ValueNotifier`).
class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        final isOn = value.torchState == TorchState.on;
        return _CircleIconButton(
          icon: isOn ? Icons.flash_on : Icons.flash_off,
          tooltip: 'Toggle torch',
          onPressed: () => controller.toggleTorch(),
        );
      },
    );
  }
}

/// Gallery import. Picks an image from the gallery; in barcode mode the picked
/// image is decoded for a barcode via [MobileScannerController.analyzeImage]
/// (on-device symbology decode is ours), in label mode the image is submitted
/// for backend OCR.
class _GalleryButton extends ConsumerWidget {
  const _GalleryButton({required this.controller, required this.mode});

  final MobileScannerController controller;
  final ScanMode mode;

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(scanCaptureControllerProvider.notifier);

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    if (mode == ScanMode.label) {
      await notifier.captureLabel(file.path);
      return;
    }

    // Barcode mode: decode the picked image on-device.
    final capture = await controller.analyzeImage(file.path);
    final barcodes = capture?.barcodes ?? const [];
    for (final barcode in barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;
      await notifier.scanBarcode(value: value, symbology: barcode.format.name);
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('No barcode found in that image')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CircleIconButton(
      icon: Icons.photo_library_outlined,
      tooltip: 'Import from gallery',
      onPressed: () => _pickFromGallery(context, ref),
    );
  }
}

/// Large capture button shown only in label mode. Opens the camera to take a
/// still photo of the label, then submits it for backend OCR (§5.3).
class _ShutterButton extends ConsumerWidget {
  const _ShutterButton();

  Future<void> _capture(WidgetRef ref) async {
    final notifier = ref.read(scanCaptureControllerProvider.notifier);
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) return;
    await notifier.captureLabel(file.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _capture(ref),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white70, width: 4),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
      ),
    );
  }
}

/// Shared circular icon button styling for the bottom control bar.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

/// Full-screen scrim driven by [ScanCaptureState], covering the camera while
/// the app is submitting, processing, or has failed. No overlay while idle.
class _StatusOverlay extends ConsumerWidget {
  const _StatusOverlay({required this.state, required this.mode});

  final ScanCaptureState state;
  final ScanMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(child: _content(context, ref)),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref) {
    final state = this.state;
    return switch (state) {
      ScanSubmitting() => _MessageWithSpinner(
        message: mode == ScanMode.barcode ? 'Looking up…' : 'Uploading…',
      ),
      ScanProcessing() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _MessageWithSpinner(
            message: 'Processing… this can take a moment',
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () =>
                ref.read(scanCaptureControllerProvider.notifier).cancel(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      ScanFailure(:final message) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  ref.read(scanCaptureControllerProvider.notifier).reset(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
      ScanSuccess() => const _MessageWithSpinner(message: 'Success!'),
      ScanIdle() => const SizedBox.shrink(),
    };
  }
}

/// Small reusable "spinner + message" pairing for the status overlay.
class _MessageWithSpinner extends StatelessWidget {
  const _MessageWithSpinner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
