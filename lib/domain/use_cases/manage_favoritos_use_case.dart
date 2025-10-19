import '../repositories/local_storage_repository.dart';

/// Use case to manage favorites
class ManageFavoritosUseCase {
  final LocalStorageRepository repository;

  ManageFavoritosUseCase(this.repository);

  Future<void> agregarFavorito(int recetaId) async {
    await repository.agregarFavorito(recetaId);
  }

  Future<void> eliminarFavorito(int recetaId) async {
    await repository.eliminarFavorito(recetaId);
  }

  Future<List<int>> obtenerTodosFavoritos() async {
    return await repository.obtenerTodosFavoritos();
  }

  Future<bool> esFavorito(int recetaId) async {
    return await repository.esFavorito(recetaId);
  }
}
