import 'package:edc_matcher/edc_matcher.dart';
import 'package:postgres/postgres.dart';

/// Typed repository over [edc_entries] + [edc_aliases].
/// Accepts any [Session] — pass a [Connection] or [Pool] from outside.
class EdcRepository {
  const EdcRepository(this._conn);

  final Session _conn;

  Future<List<EdcEntry>> findAll() async {
    final rows = await _conn.execute('''
      SELECT
        e.id, e.name, e.abbreviation, e.common_sources,
        e.scan_method, e.app_detection_method, e.lab_confirmation_method,
        e.severity, e.evidence_tier,
        e.mechanism, e.pediatric_harms, e.adult_harms,
        e.guideline_value, e.guideline_authority,
        e.reference_range, e.reference_source_url,
        e.draft_app_output_message, e.notes,
        COALESCE(
          array_agg(a.alias ORDER BY a.alias)
          FILTER (WHERE a.alias IS NOT NULL), '{}'
        ) AS aliases
      FROM edc_entries e
      LEFT JOIN edc_aliases a ON a.edc_entry_id = e.id
      GROUP BY e.id
      ORDER BY e.name
    ''');
    return rows.map(_rowToEntry).toList();
  }

  Future<EdcEntry?> findById(String id) async {
    final rows = await _conn.execute(
      Sql.named('''
        SELECT
          e.id, e.name, e.abbreviation, e.common_sources,
          e.scan_method, e.app_detection_method, e.lab_confirmation_method,
          e.severity, e.evidence_tier,
          e.mechanism, e.pediatric_harms, e.adult_harms,
          e.guideline_value, e.guideline_authority,
          e.reference_range, e.reference_source_url,
          e.draft_app_output_message, e.notes,
          COALESCE(
            array_agg(a.alias ORDER BY a.alias)
            FILTER (WHERE a.alias IS NOT NULL), '{}'
          ) AS aliases
        FROM edc_entries e
        LEFT JOIN edc_aliases a ON a.edc_entry_id = e.id
        WHERE e.id = @id
        GROUP BY e.id
      '''),
      parameters: {'id': id},
    );
    if (rows.isEmpty) return null;
    return _rowToEntry(rows.first);
  }

  EdcEntry _rowToEntry(ResultRow row) {
    final c = row.toColumnMap();
    return EdcEntry(
      id: c['id'] as String,
      name: c['name'] as String,
      abbreviation: c['abbreviation'] as String?,
      aliases: (c['aliases'] as List).cast<String>(),
      commonSources: (c['common_sources'] as List).cast<String>(),
      scanMethod: c['scan_method'] as String?,
      appDetectionMethod: c['app_detection_method'] as String?,
      labConfirmationMethod: c['lab_confirmation_method'] as String?,
      severity: c['severity'] as String,
      evidenceTier: c['evidence_tier'] as String?,
      mechanism: c['mechanism'] as String?,
      pediatricHarms: c['pediatric_harms'] as String?,
      adultHarms: c['adult_harms'] as String?,
      guidelineValue: c['guideline_value'] as String?,
      guidelineAuthority: c['guideline_authority'] as String?,
      referenceRange: c['reference_range'] as String?,
      referenceSourceUrl: c['reference_source_url'] as String?,
      draftAppOutputMessage: c['draft_app_output_message'] as String?,
      notes: c['notes'] as String?,
    );
  }
}
