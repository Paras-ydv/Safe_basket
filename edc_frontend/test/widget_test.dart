// Smoke test for the Home screen. Establishes the provider-override test
// pattern: swap the real repository binding for a fake and assert the UI
// renders what the fake returns.

import 'package:edc_app/core/enums/risk_level.dart';
import 'package:edc_app/core/models/scan_result.dart';
import 'package:edc_app/core/theme/app_theme.dart';
import 'package:edc_app/features/history/application/history_providers.dart';
import 'package:edc_app/features/history/data/history_repository.dart';
import 'package:edc_app/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubHistoryRepository implements HistoryRepository {
  const _StubHistoryRepository(this._scans);

  final List<ScanResult> _scans;

  @override
  Future<List<ScanResult>> recentScans({int limit = 5}) async => _scans;

  @override
  Future<List<ScanResult>> allScans() async => _scans;
}

void main() {
  testWidgets('Home renders hero and recent scans from the repository', (
    tester,
  ) async {
    final scans = [
      ScanResult(
        scanId: 's1',
        productName: 'Test Lotion',
        scannedAt: DateTime(2026, 7, 16, 10),
        overallRisk: RiskLevel.moderate,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(
            _StubHistoryRepository(scans),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const HomeScreen(),
        ),
      ),
    );

    // Hero copy is present immediately.
    expect(find.text('Scan. Know. Protect.'), findsOneWidget);

    // Let the async recent-scans provider resolve.
    await tester.pumpAndSettle();

    // The fake repository's scan is rendered.
    expect(find.text('Test Lotion'), findsOneWidget);
  });
}
