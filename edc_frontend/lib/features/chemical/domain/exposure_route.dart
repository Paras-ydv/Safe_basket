/// How a chemical can enter the body. The backend supplies the applicable
/// routes; the client only renders them (docs/flutter_app_architecture.md §5.5).
enum ExposureRoute {
  dermal,
  ingestion,
  inhalation;

  String get label => switch (this) {
    ExposureRoute.dermal => 'Dermal',
    ExposureRoute.ingestion => 'Ingestion',
    ExposureRoute.inhalation => 'Inhalation',
  };
}
