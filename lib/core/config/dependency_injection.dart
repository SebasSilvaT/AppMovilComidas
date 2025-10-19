import '../../domain/repositories/receta_repository.dart';
import '../../domain/repositories/local_storage_repository.dart';
import '../../domain/use_cases/get_recetas_use_case.dart';
import '../../domain/use_cases/get_receta_by_id_use_case.dart';
import '../../domain/use_cases/manage_favoritos_use_case.dart';
import '../../domain/use_cases/manage_lista_compras_use_case.dart';
import '../../infrastructure/data_sources/receta_remote_data_source.dart';
import '../../infrastructure/data_sources/local_data_source.dart';
import '../../infrastructure/repositories/receta_repository_impl.dart';
import '../../infrastructure/repositories/local_storage_repository_impl.dart';

/// Dependency Injection Container
/// This class manages all dependencies and provides them to the app
class DependencyInjection {
  // Data Sources
  static final RecetaRemoteDataSource _recetaRemoteDataSource = RecetaRemoteDataSource();
  static final LocalDataSource _localDataSource = LocalDataSource();

  // Repositories
  static final RecetaRepository _recetaRepository = RecetaRepositoryImpl(_recetaRemoteDataSource);
  static final LocalStorageRepository _localStorageRepository = LocalStorageRepositoryImpl(_localDataSource);

  // Use Cases
  static final GetRecetasUseCase getRecetasUseCase = GetRecetasUseCase(_recetaRepository);
  static final GetRecetaByIdUseCase getRecetaByIdUseCase = GetRecetaByIdUseCase(_recetaRepository);
  static final ManageFavoritosUseCase manageFavoritosUseCase = ManageFavoritosUseCase(_localStorageRepository);
  static final ManageListaComprasUseCase manageListaComprasUseCase = ManageListaComprasUseCase(_localStorageRepository);

  // Initialize database
  static Future<void> initialize() async {
    await LocalDataSource.initializeDatabase();
  }
}
