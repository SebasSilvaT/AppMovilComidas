import '../../domain/entities/ingrediente.dart';
import '../../domain/repositories/local_storage_repository.dart';
import '../data_sources/local_data_source.dart';

/// Implementation of LocalStorageRepository
class LocalStorageRepositoryImpl implements LocalStorageRepository {
  final LocalDataSource localDataSource;

  LocalStorageRepositoryImpl(this.localDataSource);

  @override
  Future<void> agregarFavorito(int recetaId) async {
    await localDataSource.agregarFavorito(recetaId);
  }

  @override
  Future<void> eliminarFavorito(int recetaId) async {
    await localDataSource.eliminarFavorito(recetaId);
  }

  @override
  Future<List<int>> obtenerTodosFavoritos() async {
    return await localDataSource.obtenerTodosFavoritos();
  }

  @override
  Future<bool> esFavorito(int recetaId) async {
    return await localDataSource.esFavorito(recetaId);
  }

  @override
  Future<void> agregarAListaCompras(int recetaId, List<Ingrediente> ingredientes) async {
    await localDataSource.agregarIngredientesALista(recetaId, ingredientes);
  }

  @override
  Future<void> eliminarDeListaCompras(String ingredienteNombre) async {
    await localDataSource.eliminarIngredienteDeLista(ingredienteNombre);
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerListaCompras() async {
    return await localDataSource.obtenerListaCompras();
  }

  @override
  Future<void> limpiarListaCompras() async {
    await localDataSource.limpiarListaCompras();
  }

  @override
  Future<void> actualizarCantidadIngrediente(String nombreIngrediente, double nuevaCantidad) async {
    await localDataSource.actualizarCantidadIngrediente(nombreIngrediente, nuevaCantidad);
  }
}
