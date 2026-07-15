import 'package:edc_matcher/edc_matcher.dart';
import 'package:edc_backend/ocr/match_service.dart';
import 'package:test/test.dart';

// Minimal EdcEntry that matches on the alias "methylparaben".
// Mirrors the real entry in edc_database.json — aliases include "methylparaben"
// and "parabens", severity "Low-Moderate".
EdcEntry _methylparaben() => EdcEntry(
      id: 'methylparaben',
      name: 'Methylparaben',
      abbreviation: null,
      aliases: ['methylparaben', 'paraben', 'parabens', 'propylparaben', 'butylparaben'],
      commonSources: ['personal care products', 'cosmetics'],
      severity: 'Low-Moderate',
      evidenceTier: 'Limited',
      mechanism: 'Weak estrogenic activity via estrogen receptor binding',
      pediatricHarms: 'Early breast development (limited evidence)',
      adultHarms: 'Hormonal imbalance (weak evidence)',
      draftAppOutputMessage: 'Weak estrogenic activity detected',
      // ECHA/OECD defaults — not relevant to matching
      echaSvhcListed: false,
      echaModality: const [],
      echaAssessmentOutcome: EchaAssessmentOutcome.notYetAssessed,
      echaRegulatoryContext: EchaRegulatoryContext.outsideEchaScope,
      oecdEvidenceLevels: const [],
      needsVerification: true,
    );

void main() {
  group('matchAndClassify — cache population regression', () {
    // This test catches the bug where routes/scan/_middleware.dart provided
    // const _entries = <EdcEntry>[] instead of EdcCache.entries, causing
    // every /scan/photo request to return zero matches regardless of input.
    test('returns non-empty matches when entry list is populated', () {
      final result = matchAndClassify(
        'Water, Methylparaben, Fragrance',
        [_methylparaben()],
      );

      expect(result.matches, isNotEmpty,
          reason: 'Empty matches means the entry list was not wired up correctly');
      expect(result.matches.first.id, 'methylparaben');
      expect(result.worstSeverity, 'Low-Moderate');
    });

    test('returns empty matches when entry list is empty — the broken state', () {
      final result = matchAndClassify(
        'Water, Methylparaben, Fragrance',
        const [],
      );

      expect(result.matches, isEmpty,
          reason: 'This is the broken state — if this is the only passing test, '
              'the cache is not being wired into the route');
    });

    test('matches on alias, not just canonical name', () {
      // "parabens" is an alias, not the entry name — alias matching must work
      final result = matchAndClassify(
        'Aqua, Parabens, Parfum',
        [_methylparaben()],
      );

      expect(result.matches, isNotEmpty);
      expect(result.matches.first.id, 'methylparaben');
    });

    test('match is case-insensitive', () {
      final result = matchAndClassify(
        'WATER, METHYLPARABEN, FRAGRANCE',
        [_methylparaben()],
      );

      expect(result.matches, isNotEmpty);
    });
  });
}
