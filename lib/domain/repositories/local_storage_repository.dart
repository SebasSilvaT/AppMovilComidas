import '../entities/ingrediente.dart';

/// Repository interface for local storage operations
/// This is the contract that infrastructure layer must implement
abstract class LocalStorageRepository {
  // Favoritos
  Future<void> agregarFavorito(int recetaId);
  Future<void> eliminarFavorito(int recetaId);
  Future<List<int>> obtenerTodosFavoritos();
  Future<bool> esFavorito(int recetaId);

  // Lista de compras
  Future<void> agregarAListaCompras(int recetaId, List<Ingrediente> ingredientes);
  Future<void> eliminarDeListaCompras(String ingredienteNombre);
  Future<List<Map<String, dynamic>>> obtenerListaCompras();
  Future<void> limpiarListaCompras();
  Future<void> actualizarCantidadIngrediente(String nombreIngrediente, double nuevaCantidad);
}
