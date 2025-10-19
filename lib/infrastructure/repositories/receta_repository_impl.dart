import '../../domain/entities/receta.dart';
import '../../domain/repositories/receta_repository.dart';
import '../data_sources/receta_remote_data_source.dart';

/// Implementation of RecetaRepository
class RecetaRepositoryImpl implements RecetaRepository {
  final RecetaRemoteDataSource remoteDataSource;

  RecetaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Receta>> getRecetas() async {
    return await remoteDataSource.getRecetas();
  }

  @override
  Future<Receta> getRecetaById(int id) async {
    return await remoteDataSource.getRecetaById(id);
  }
}
