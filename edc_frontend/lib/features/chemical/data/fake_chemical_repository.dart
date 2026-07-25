import '../../../core/enums/risk_level.dart';
import '../domain/alternative.dart';
import '../domain/chemical_detail.dart';
import '../domain/exposure_route.dart';
import 'chemical_repository.dart';

/// Canned [ChemicalRepository] used while the backend knowledge base is not yet
/// wired up (docs/flutter_app_architecture.md §3 — develop against a fake).
class FakeChemicalRepository implements ChemicalRepository {
  const FakeChemicalRepository();

  @override
  Future<ChemicalDetail> getChemical(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // A single canned profile keyed by whatever id is requested.
    return ChemicalDetail(
      id: id,
      name: 'Bisphenol A (BPA)',
      risk: RiskLevel.high,
      chemicalClass: 'Diphenylmethane derivative · synthetic',
      healthEffects: const [
        'Endocrine disruption (estrogen mimicry)',
        'Potential reproductive and developmental effects',
        'Associated with metabolic and cardiovascular concerns',
      ],
      exposureRoutes: const [
        ExposureRoute.dermal,
        ExposureRoute.ingestion,
      ],
      regulatoryStatus:
          'Restricted in food-contact materials (EU 2018/213); listed by ECHA '
          'as a substance of very high concern.',
    );
  }

  @override
  Future<List<Alternative>> getAlternatives(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const [
      Alternative(
        id: 'glass',
        name: 'Glass or stainless-steel containers',
        risk: RiskLevel.low,
        note: 'Avoids bisphenol migration from plastics entirely.',
      ),
      Alternative(
        id: 'bpa-free-tritan',
        name: 'BPA-free Tritan copolyester',
        risk: RiskLevel.low,
        note: 'Manufactured without bisphenol A.',
      ),
      Alternative(
        id: 'polypropylene',
        name: 'Polypropylene (#5) containers',
        risk: RiskLevel.moderate,
        note: 'Lower concern than polycarbonate, but avoid heating.',
      ),
    ];
  }
}
