import '../entities/receta.dart';
import '../repositories/receta_repository.dart';

/// Use case to get a single recipe by ID
class GetRecetaByIdUseCase {
  final RecetaRepository repository;

  GetRecetaByIdUseCase(this.repository);

  Future<Receta> execute(int id) async {
    return await repository.getRecetaById(id);
  }
}
