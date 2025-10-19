import '../entities/receta.dart';
import '../repositories/receta_repository.dart';

/// Use case to get all recipes from API
class GetRecetasUseCase {
  final RecetaRepository repository;

  GetRecetasUseCase(this.repository);

  Future<List<Receta>> execute() async {
    return await repository.getRecetas();
  }
}
