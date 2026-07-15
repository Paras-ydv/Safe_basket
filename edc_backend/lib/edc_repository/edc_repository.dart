import 'package:edc_matcher/edc_matcher.dart';
import 'package:postgres/postgres.dart';

/// Typed repository over [edc_entries] + [edc_aliases].
/// Accepts any [Session] — pass a [Connection] or [Pool] from outside.
class EdcRepository {
  const EdcRepository(this._conn);

  final Session _conn;

  // ── Reads ──────────────────────────────────────────────────────────────────

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

  // ── Writes ─────────────────────────────────────────────────────────────────

  /// Inserts a new entry. Throws [StateError] if [id] already exists.
  Future<void> insert(EdcEntryInput input) async {
    await _conn.execute(
      Sql.named('''
        INSERT INTO edc_entries (
          id, name, abbreviation, common_sources,
          scan_method, app_detection_method, lab_confirmation_method,
          severity, evidence_tier,
          mechanism, pediatric_harms, adult_harms,
          guideline_value, guideline_authority,
          reference_range, reference_source_url,
          draft_app_output_message, notes,
          last_reviewed_date, reviewed_by
        ) VALUES (
          @id, @name, @abbreviation, @common_sources,
          @scan_method, @app_detection_method, @lab_confirmation_method,
          @severity, @evidence_tier,
          @mechanism, @pediatric_harms, @adult_harms,
          @guideline_value, @guideline_authority,
          @reference_range, @reference_source_url,
          @draft_app_output_message, @notes,
          @last_reviewed_date, @reviewed_by
        )
      '''),
      parameters: _inputToParams(input),
    );
  }

  /// Updates an existing entry's fields. Only non-null fields in [input] are
  /// written; omitted fields are left unchanged via COALESCE.
  Future<bool> update(String id, EdcEntryInput input) async {
    final result = await _conn.execute(
      Sql.named('''
        UPDATE edc_entries SET
          name                    = COALESCE(@name, name),
          abbreviation            = COALESCE(@abbreviation, abbreviation),
          common_sources          = COALESCE(@common_sources, common_sources),
          scan_method             = COALESCE(@scan_method, scan_method),
          app_detection_method    = COALESCE(@app_detection_method, app_detection_method),
          lab_confirmation_method = COALESCE(@lab_confirmation_method, lab_confirmation_method),
          severity                = COALESCE(@severity, severity),
          evidence_tier           = COALESCE(@evidence_tier, evidence_tier),
          mechanism               = COALESCE(@mechanism, mechanism),
          pediatric_harms         = COALESCE(@pediatric_harms, pediatric_harms),
          adult_harms             = COALESCE(@adult_harms, adult_harms),
          guideline_value         = COALESCE(@guideline_value, guideline_value),
          guideline_authority     = COALESCE(@guideline_authority, guideline_authority),
          reference_range         = COALESCE(@reference_range, reference_range),
          reference_source_url    = COALESCE(@reference_source_url, reference_source_url),
          draft_app_output_message= COALESCE(@draft_app_output_message, draft_app_output_message),
          notes                   = COALESCE(@notes, notes),
          last_reviewed_date      = COALESCE(@last_reviewed_date, last_reviewed_date),
          reviewed_by             = COALESCE(@reviewed_by, reviewed_by)
        WHERE id = @id
      '''),
      parameters: {'id': id, ..._inputToParams(input)},
    );
    return result.affectedRows > 0;
  }

  /// Inserts a new alias for [entryId]. Returns the new alias row id.
  /// Returns null if the alias already exists (ON CONFLICT DO NOTHING).
  Future<int?> insertAlias(String entryId, String alias) async {
    final rows = await _conn.execute(
      Sql.named('''
        INSERT INTO edc_aliases (edc_entry_id, alias)
        VALUES (@edc_entry_id, @alias)
        ON CONFLICT (edc_entry_id, alias) DO NOTHING
        RETURNING id
      '''),
      parameters: {'edc_entry_id': entryId, 'alias': alias},
    );
    if (rows.isEmpty) return null;
    return rows.first.toColumnMap()['id'] as int;
  }

  /// Deletes alias row by [aliasId]. Returns true if a row was deleted.
  Future<bool> deleteAlias(int aliasId) async {
    final result = await _conn.execute(
      Sql.named('DELETE FROM edc_aliases WHERE id = @id'),
      parameters: {'id': aliasId},
    );
    return result.affectedRows > 0;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
      // AXIS 1 — ECHA (not yet in DB schema; safe defaults)
      echaSvhcListed: false,
      echaSvhcListingDate: null,
      echaSvhcReason: null,
      echaClpEdCategory: null,
      echaModality: const [],
      echaAssessmentOutcome: EchaAssessmentOutcome.notYetAssessed,
      echaRegulatoryContext: EchaRegulatoryContext.outsideEchaScope,
      echaLastUpdated: null,
      // AXIS 2 — OECD (not yet in DB schema; safe defaults)
      oecdEvidenceLevels: const [],
      oecdEvidenceNotes: null,
      // Meta
      needsVerification: true,
    );
  }

  Map<String, dynamic> _inputToParams(EdcEntryInput i) => {
        'id': i.id,
        'name': i.name,
        'abbreviation': i.abbreviation,
        'common_sources': i.commonSources,
        'scan_method': i.scanMethod,
        'app_detection_method': i.appDetectionMethod,
        'lab_confirmation_method': i.labConfirmationMethod,
        'severity': i.severity,
        'evidence_tier': i.evidenceTier,
        'mechanism': i.mechanism,
        'pediatric_harms': i.pediatricHarms,
        'adult_harms': i.adultHarms,
        'guideline_value': i.guidelineValue,
        'guideline_authority': i.guidelineAuthority,
        'reference_range': i.referenceRange,
        'reference_source_url': i.referenceSourceUrl,
        'draft_app_output_message': i.draftAppOutputMessage,
        'notes': i.notes,
        'last_reviewed_date': i.lastReviewedDate,
        'reviewed_by': i.reviewedBy,
      };
}

/// Input model for create and update operations.
/// All fields are nullable — for updates, only non-null fields are applied.
class EdcEntryInput {
  const EdcEntryInput({
    this.id,
    this.name,
    this.abbreviation,
    this.commonSources,
    this.scanMethod,
    this.appDetectionMethod,
    this.labConfirmationMethod,
    this.severity,
    this.evidenceTier,
    this.mechanism,
    this.pediatricHarms,
    this.adultHarms,
    this.guidelineValue,
    this.guidelineAuthority,
    this.referenceRange,
    this.referenceSourceUrl,
    this.draftAppOutputMessage,
    this.notes,
    this.lastReviewedDate,
    this.reviewedBy,
  });

  final String? id;
  final String? name;
  final String? abbreviation;
  final List<String>? commonSources;
  final String? scanMethod;
  final String? appDetectionMethod;
  final String? labConfirmationMethod;
  final String? severity;
  final String? evidenceTier;
  final String? mechanism;
  final String? pediatricHarms;
  final String? adultHarms;
  final String? guidelineValue;
  final String? guidelineAuthority;
  final String? referenceRange;
  final String? referenceSourceUrl;
  final String? draftAppOutputMessage;
  final String? notes;
  final String? lastReviewedDate; // ISO-8601 date string, e.g. "2024-01-15"
  final String? reviewedBy;

  factory EdcEntryInput.fromJson(Map<String, dynamic> j) => EdcEntryInput(
        id: j['id'] as String?,
        name: j['name'] as String?,
        abbreviation: j['abbreviation'] as String?,
        commonSources: (j['common_sources'] as List?)?.cast<String>(),
        scanMethod: j['scan_method'] as String?,
        appDetectionMethod: j['app_detection_method'] as String?,
        labConfirmationMethod: j['lab_confirmation_method'] as String?,
        severity: j['severity'] as String?,
        evidenceTier: j['evidence_tier'] as String?,
        mechanism: j['mechanism'] as String?,
        pediatricHarms: j['pediatric_harms'] as String?,
        adultHarms: j['adult_harms'] as String?,
        guidelineValue: j['guideline_value'] as String?,
        guidelineAuthority: j['guideline_authority'] as String?,
        referenceRange: j['reference_range'] as String?,
        referenceSourceUrl: j['reference_source_url'] as String?,
        draftAppOutputMessage: j['draft_app_output_message'] as String?,
        notes: j['notes'] as String?,
        lastReviewedDate: j['last_reviewed_date'] as String?,
        reviewedBy: j['reviewed_by'] as String?,
      );
}
