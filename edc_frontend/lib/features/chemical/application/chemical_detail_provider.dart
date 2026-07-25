import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../data/api_chemical_repository.dart';
import '../data/chemical_repository.dart';
import '../data/fake_chemical_repository.dart';
import '../domain/alternative.dart';
import '../domain/chemical_detail.dart';

part 'chemical_detail_provider.g.dart';

/// Binding for the [ChemicalRepository]. Binds the real Dio-backed repo by
/// default; falls back to the fake with `--dart-define=USE_FAKES=true`.
@riverpod
ChemicalRepository chemicalRepository(ChemicalRepositoryRef ref) =>
    ApiConfig.useFakes
    ? const FakeChemicalRepository()
    : ApiChemicalRepository(ref.watch(dioProvider));

/// Fetches a [ChemicalDetail] by id (family provider). Orchestration only — the
/// fetch lives in the repository (§4.1).
@riverpod
Future<ChemicalDetail> chemicalDetail(ChemicalDetailRef ref, String id) {
  return ref.watch(chemicalRepositoryProvider).getChemical(id);
}

/// Safer alternatives for a chemical (family provider). Orchestration only.
@riverpod
Future<List<Alternative>> chemicalAlternatives(
  ChemicalAlternativesRef ref,
  String id,
) {
  return ref.watch(chemicalRepositoryProvider).getAlternatives(id);
}
