import '../domain/alternative.dart';
import '../domain/chemical_detail.dart';

/// Network boundary for the chemical feature (docs/flutter_app_architecture.md
/// §4.1). Returns domain models, never raw JSON. Backed by
/// [FakeChemicalRepository] until the backend `GET /chemicals/{id}` is ready.
abstract interface class ChemicalRepository {
  Future<ChemicalDetail> getChemical(String id);

  /// Safer alternatives for a chemical (`GET /chemicals/{id}/alternatives`).
  Future<List<Alternative>> getAlternatives(String id);
}
