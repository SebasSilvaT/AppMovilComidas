import '../entities/ingrediente.dart';
import '../repositories/local_storage_repository.dart';

/// Use case to manage shopping list
class ManageListaComprasUseCase {
  final LocalStorageRepository repository;

  ManageListaComprasUseCase(this.repository);

  Future<void> agregarAListaCompras(int recetaId, List<Ingrediente> ingredientes) async {
    await repository.agregarAListaCompras(recetaId, ingredientes);
  }

  Future<void> eliminarDeListaCompras(String ingredienteNombre) async {
    await repository.eliminarDeListaCompras(ingredienteNombre);
  }

  Future<List<Map<String, dynamic>>> obtenerListaCompras() async {
    return await repository.obtenerListaCompras();
  }

  Future<void> limpiarListaCompras() async {
    await repository.limpiarListaCompras();
  }

  Future<void> actualizarCantidadIngrediente(String nombreIngrediente, double nuevaCantidad) async {
    await repository.actualizarCantidadIngrediente(nombreIngrediente, nuevaCantidad);
  }
}
