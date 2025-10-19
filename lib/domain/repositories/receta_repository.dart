import '../entities/receta.dart';

/// Repository interface for Recipe operations
/// This is the contract that infrastructure layer must implement
abstract class RecetaRepository {
  Future<List<Receta>> getRecetas();
  Future<Receta> getRecetaById(int id);
}
