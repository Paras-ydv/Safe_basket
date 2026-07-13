// db/seeds/seed_edc.dart
// One-time seed script — reads the real edc_database.json and inserts into
// edc_entries + edc_aliases. Idempotent: ON CONFLICT DO NOTHING on both tables.
//
// Usage (from edc_backend/ directory):
//   dart run db/seeds/seed_edc.dart

import 'dart:convert';
import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:edc_backend/config.dart';

Future<void> main() async {
  final config = AppConfig.load();
  final conn = await config.openConnection();

  final jsonFile = File('db/seeds/edc_database.json');
  final decoded = jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;
  final entries = (decoded['entries'] as List).cast<Map<String, dynamic>>();

  await conn.runTx((tx) async {
    for (final e in entries) {
      final id = e['id'] as String;

      // commonSources is List<String> in JSON → TEXT[] in Postgres
      final commonSources = (e['commonSources'] as List? ?? []).cast<String>();
      final aliases = (e['aliases'] as List? ?? []).cast<String>();

      await tx.execute(
        Sql.named('''
          INSERT INTO edc_entries (
            id, name, abbreviation, common_sources,
            scan_method, app_detection_method, lab_confirmation_method,
            severity, evidence_tier,
            mechanism, pediatric_harms, adult_harms,
            guideline_value, guideline_authority,
            reference_range, reference_source_url,
            draft_app_output_message, notes
          ) VALUES (
            @id, @name, @abbreviation, @common_sources,
            @scan_method, @app_detection_method, @lab_confirmation_method,
            @severity, @evidence_tier,
            @mechanism, @pediatric_harms, @adult_harms,
            @guideline_value, @guideline_authority,
            @reference_range, @reference_source_url,
            @draft_app_output_message, @notes
          )
          ON CONFLICT (id) DO NOTHING
        '''),
        parameters: {
          'id': id,
          'name': e['name'] as String,
          'abbreviation': e['abbreviation'] as String?,
          'common_sources': commonSources,
          'scan_method': e['scanMethod'] as String?,
          'app_detection_method': e['appDetectionMethod'] as String?,
          'lab_confirmation_method': e['labConfirmationMethod'] as String?,
          'severity': e['severity'] as String,
          'evidence_tier': e['evidenceTier'] as String?,
          'mechanism': e['mechanism'] as String?,
          'pediatric_harms': e['pediatricHarms'] as String?,
          'adult_harms': e['adultHarms'] as String?,
          'guideline_value': e['guidelineValue'] as String?,
          'guideline_authority': e['guidelineAuthority'] as String?,
          'reference_range': e['referenceRange'] as String?,
          'reference_source_url': e['referenceSourceUrl'] as String?,
          'draft_app_output_message': e['draftAppOutputMessage'] as String?,
          'notes': e['notes'] as String?,
        },
      );

      for (final alias in aliases) {
        await tx.execute(
          Sql.named('''
            INSERT INTO edc_aliases (edc_entry_id, alias)
            VALUES (@edc_entry_id, @alias)
            ON CONFLICT (edc_entry_id, alias) DO NOTHING
          '''),
          parameters: {'edc_entry_id': id, 'alias': alias},
        );
      }
    }
  });

  await conn.close();
  stdout.writeln('Seeded ${entries.length} EDC entries.');
}
