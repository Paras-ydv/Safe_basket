/// Represents a known EDC (Endocrine Disrupting Chemical) entry.
///
/// [severity] is free-form text, not an enum. Real values include:
/// "High", "Moderate-High", "Moderate", "Low-Moderate", "Dose-dependent",
/// "Low", "Emerging", "Acute", "Non-EDC".
/// These are hedged/compound categories that do not collapse into a clean enum.
///
/// [evidenceTier] is a separate concept: "Strong", "Moderate", "Limited", or
/// null for entries where evidence tier is not established (e.g. Non-EDC,
/// Acute entries).
class EdcEntry {
  const EdcEntry({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.aliases,
    required this.commonSources,
    this.scanMethod,
    this.appDetectionMethod,
    this.labConfirmationMethod,
    required this.severity,
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
  });

  final String id;
  final String name;
  final String? abbreviation;
  final List<String> aliases;
  final List<String> commonSources;
  final String? scanMethod;
  final String? appDetectionMethod;
  final String? labConfirmationMethod;
  final String severity;
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
}
