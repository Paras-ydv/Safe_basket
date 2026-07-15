// ── Enums ─────────────────────────────────────────────────────────────────────

/// ECHA CLP endocrine-disrupting category.
/// null means the substance has not been classified under CLP ED criteria.
enum EchaClpEdCategory {
  edHh1('ED HH 1'),
  edHh2('ED HH 2'),
  edEnv1('ED ENV 1'),
  edEnv2('ED ENV 2'),
  notClassified('Not classified');

  const EchaClpEdCategory(this.label);
  final String label;

  static EchaClpEdCategory? fromJson(String? value) {
    if (value == null) return null;
    return EchaClpEdCategory.values.firstWhere((e) => e.label == value);
  }

  String toJson() => label;
}

/// ECHA endocrine-disruption modality.
/// An entry may have multiple modalities — stored as [List<EchaModality>].
enum EchaModality {
  estrogenic('Estrogenic'),
  androgenic('Androgenic'),
  thyroid('Thyroid'),
  steroidogenic('Steroidogenic'),
  nonEats('Non-EATS');

  const EchaModality(this.label);
  final String label;

  static EchaModality fromJson(String value) =>
      EchaModality.values.firstWhere((e) => e.label == value);

  String toJson() => label;
}

/// ECHA assessment outcome for endocrine-disrupting properties.
enum EchaAssessmentOutcome {
  confirmedEdProperties('Confirmed ED properties'),
  assessedNotConfirmed('Assessed - not confirmed'),
  underAssessment('Under assessment'),
  notYetAssessed('Not yet assessed'),
  outsideEchaRegulatoryScope('Outside ECHA regulatory scope');

  const EchaAssessmentOutcome(this.label);
  final String label;

  static EchaAssessmentOutcome fromJson(String value) =>
      EchaAssessmentOutcome.values.firstWhere((e) => e.label == value);

  String toJson() => label;
}

/// The ECHA regulatory framework under which this substance is assessed.
enum EchaRegulatoryContext {
  reach('REACH'),
  bpr('BPR'),
  pppr('PPPR'),
  outsideEchaScope('Outside ECHA scope');

  const EchaRegulatoryContext(this.label);
  final String label;

  static EchaRegulatoryContext fromJson(String value) =>
      EchaRegulatoryContext.values.firstWhere((e) => e.label == value);

  String toJson() => label;
}

// ── EdcEntry ──────────────────────────────────────────────────────────────────

/// Represents a known EDC (Endocrine Disrupting Chemical) entry.
///
/// Evidence is structured along two independent axes:
///
/// AXIS 1 — ECHA regulatory status: whether the substance is listed as an
/// SVHC, its CLP ED category, modality, assessment outcome, and the
/// regulatory framework under which it was assessed.
///
/// AXIS 2 — OECD Conceptual Framework evidence level: which of the five
/// OECD CF tiers (1 = physicochemical, 2 = in vitro, 3 = in vivo mechanistic,
/// 4 = in vivo apical, 5 = in vivo multi-generation) have data available.
/// Levels are non-sequential — a substance may have data at levels 2 and 4
/// but not 3.
///
/// [needsVerification] is true when the ECHA status fields have been
/// populated from a bulk source and have not yet been individually confirmed
/// against the ECHA dissemination portal.
class EdcEntry {
  const EdcEntry({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.aliases,
    required this.commonSources,
    required this.severity,
    this.evidenceTier,
    this.guidelineValue,
    this.guidelineAuthority,
    this.scanMethod,
    this.appDetectionMethod,
    this.labConfirmationMethod,
    this.mechanism,
    this.pediatricHarms,
    this.adultHarms,
    this.referenceRange,
    this.referenceSourceUrl,
    this.draftAppOutputMessage,
    this.notes,
    // AXIS 1 — ECHA
    required this.echaSvhcListed,
    this.echaSvhcListingDate,
    this.echaSvhcReason,
    this.echaClpEdCategory,
    required this.echaModality,
    required this.echaAssessmentOutcome,
    required this.echaRegulatoryContext,
    this.echaLastUpdated,
    // AXIS 2 — OECD
    required this.oecdEvidenceLevels,
    this.oecdEvidenceNotes,
    // Meta
    required this.needsVerification,
  });

  final String id;
  final String name;
  final String? abbreviation;
  final List<String> aliases;
  final List<String> commonSources;
  final String severity;
  final String? evidenceTier;
  final String? guidelineValue;
  final String? guidelineAuthority;
  final String? scanMethod;
  final String? appDetectionMethod;
  final String? labConfirmationMethod;
  final String? mechanism;
  final String? pediatricHarms;
  final String? adultHarms;
  final String? referenceRange;
  final String? referenceSourceUrl;
  final String? draftAppOutputMessage;
  final String? notes;

  // ── AXIS 1 — ECHA regulatory status ────────────────────────────────────────

  /// Whether this substance appears on the ECHA SVHC Candidate List.
  final bool echaSvhcListed;

  /// Date the substance was added to the SVHC Candidate List, if applicable.
  final DateTime? echaSvhcListingDate;

  /// The Article 57 reason for SVHC listing, e.g.
  /// "Article 57(f) — endocrine-disrupting properties, human health".
  final String? echaSvhcReason;

  /// CLP endocrine-disrupting category, or null if not classified.
  final EchaClpEdCategory? echaClpEdCategory;

  /// Endocrine-disruption modalities identified for this substance.
  /// May be empty if modality has not been assessed.
  final List<EchaModality> echaModality;

  /// ECHA's assessment outcome for endocrine-disrupting properties.
  final EchaAssessmentOutcome echaAssessmentOutcome;

  /// The regulatory framework under which this substance was assessed.
  final EchaRegulatoryContext echaRegulatoryContext;

  /// Date the ECHA record was last updated.
  final DateTime? echaLastUpdated;

  // ── AXIS 2 — OECD Conceptual Framework evidence level ──────────────────────

  /// OECD CF tiers (1–5) for which data exists. Non-sequential, may be empty.
  final List<int> oecdEvidenceLevels;

  /// Short description of what data exists at the cited OECD CF levels.
  final String? oecdEvidenceNotes;

  // ── Meta ───────────────────────────────────────────────────────────────────

  /// True if this entry's ECHA status has not yet been individually confirmed
  /// against the ECHA dissemination portal.
  final bool needsVerification;

  // ── Serialisation ──────────────────────────────────────────────────────────

  factory EdcEntry.fromJson(Map<String, dynamic> j) => EdcEntry(
        id: j['id'] as String,
        name: j['name'] as String,
        abbreviation: j['abbreviation'] as String?,
        aliases: (j['aliases'] as List).cast<String>(),
        commonSources: (j['commonSources'] as List).cast<String>(),
        severity: j['severity'] as String,
        evidenceTier: j['evidenceTier'] as String?,
        guidelineValue: j['guidelineValue'] as String?,
        guidelineAuthority: j['guidelineAuthority'] as String?,
        scanMethod: j['scanMethod'] as String?,
        appDetectionMethod: j['appDetectionMethod'] as String?,
        labConfirmationMethod: j['labConfirmationMethod'] as String?,
        mechanism: j['mechanism'] as String?,
        pediatricHarms: j['pediatricHarms'] as String?,
        adultHarms: j['adultHarms'] as String?,
        referenceRange: j['referenceRange'] as String?,
        referenceSourceUrl: j['referenceSourceUrl'] as String?,
        draftAppOutputMessage: j['draftAppOutputMessage'] as String?,
        notes: j['notes'] as String?,
        // AXIS 1
        echaSvhcListed: j['echaSvhcListed'] as bool,
        echaSvhcListingDate: j['echaSvhcListingDate'] == null
            ? null
            : DateTime.parse(j['echaSvhcListingDate'] as String),
        echaSvhcReason: j['echaSvhcReason'] as String?,
        echaClpEdCategory:
            EchaClpEdCategory.fromJson(j['echaClpEdCategory'] as String?),
        echaModality: (j['echaModality'] as List)
            .cast<String>()
            .map(EchaModality.fromJson)
            .toList(),
        echaAssessmentOutcome: EchaAssessmentOutcome.fromJson(
            j['echaAssessmentOutcome'] as String),
        echaRegulatoryContext: EchaRegulatoryContext.fromJson(
            j['echaRegulatoryContext'] as String),
        echaLastUpdated: j['echaLastUpdated'] == null
            ? null
            : DateTime.parse(j['echaLastUpdated'] as String),
        // AXIS 2
        oecdEvidenceLevels:
            (j['oecdEvidenceLevels'] as List).cast<int>(),
        oecdEvidenceNotes: j['oecdEvidenceNotes'] as String?,
        // Meta
        needsVerification: j['needsVerification'] as bool,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'abbreviation': abbreviation,
        'aliases': aliases,
        'commonSources': commonSources,
        'severity': severity,
        'evidenceTier': evidenceTier,
        'guidelineValue': guidelineValue,
        'guidelineAuthority': guidelineAuthority,
        'scanMethod': scanMethod,
        'appDetectionMethod': appDetectionMethod,
        'labConfirmationMethod': labConfirmationMethod,
        'mechanism': mechanism,
        'pediatricHarms': pediatricHarms,
        'adultHarms': adultHarms,
        'referenceRange': referenceRange,
        'referenceSourceUrl': referenceSourceUrl,
        'draftAppOutputMessage': draftAppOutputMessage,
        'notes': notes,
        // AXIS 1
        'echaSvhcListed': echaSvhcListed,
        'echaSvhcListingDate': echaSvhcListingDate?.toIso8601String(),
        'echaSvhcReason': echaSvhcReason,
        'echaClpEdCategory': echaClpEdCategory?.toJson(),
        'echaModality': echaModality.map((m) => m.toJson()).toList(),
        'echaAssessmentOutcome': echaAssessmentOutcome.toJson(),
        'echaRegulatoryContext': echaRegulatoryContext.toJson(),
        'echaLastUpdated': echaLastUpdated?.toIso8601String(),
        // AXIS 2
        'oecdEvidenceLevels': oecdEvidenceLevels,
        'oecdEvidenceNotes': oecdEvidenceNotes,
        // Meta
        'needsVerification': needsVerification,
      };
}
