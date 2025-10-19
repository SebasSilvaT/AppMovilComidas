# Arquitectura DDD (Domain-Driven Design)

## 📁 Estructura del Proyecto

Este proyecto ha sido reorganizado siguiendo el patrón **Domain-Driven Design (DDD)**, que proporciona una arquitectura limpia, escalable y mantenible.

```
lib/
├── core/                          # Configuración y utilidades globales
│   └── config/
│       └── dependency_injection.dart
│
├── domain/                        # Capa de dominio (lógica de negocio)
│   ├── entities/                  # Entidades del dominio
│   │   ├── ingrediente.dart
│   │   └── receta.dart
│   ├── repositories/              # Interfaces de repositorios
│   │   ├── local_storage_repository.dart
│   │   └── receta_repository.dart
│   └── use_cases/                 # Casos de uso (lógica de negocio)
│       ├── get_recetas_use_case.dart
│       ├── get_receta_by_id_use_case.dart
│       ├── manage_favoritos_use_case.dart
│       └── manage_lista_compras_use_case.dart
│
├── infrastructure/                # Capa de infraestructura (implementaciones)
│   ├── data_sources/              # Fuentes de datos
│   │   ├── local_data_source.dart      # SQLite
│   │   └── receta_remote_data_source.dart  # API REST
│   └── repositories/              # Implementaciones de repositorios
│       ├── local_storage_repository_impl.dart
│       └── receta_repository_impl.dart
│
└── presentation/                  # Capa de presentación (UI)
    ├── pages/                     # Pantallas de la aplicación
    │   ├── favoritos_page.dart
    │   ├── home_page.dart
    │   ├── lista_compras_page.dart
    │   ├── recetas_page.dart
    │   └── receta_detalle_page.dart
    └── widgets/                   # Widgets reutilizables (futuro)
```

## 🏛️ Capas de la Arquitectura

### 1. **Domain Layer (Dominio)**
La capa más interna y pura de la aplicación. No tiene dependencias de otras capas.

- **Entities**: Objetos de negocio puros
  - `Receta`: Representa una receta con sus ingredientes
  - `Ingrediente`: Representa un ingrediente individual

- **Repositories**: Interfaces que definen contratos (no implementaciones)
  - `RecetaRepository`: Contrato para operaciones de recetas
  - `LocalStorageRepository`: Contrato para almacenamiento local

- **Use Cases**: Lógica de negocio específica
  - `GetRecetasUseCase`: Obtener todas las recetas
  - `GetRecetaByIdUseCase`: Obtener una receta específica
  - `ManageFavoritosUseCase`: Gestionar favoritos
  - `ManageListaComprasUseCase`: Gestionar lista de compras

### 2. **Infrastructure Layer (Infraestructura)**
Implementaciones concretas de las interfaces del dominio.

- **Data Sources**: Acceso directo a fuentes de datos
  - `RecetaRemoteDataSource`: Comunicación con API REST
  - `LocalDataSource`: Operaciones con SQLite

- **Repository Implementations**: Implementaciones de los repositorios
  - `RecetaRepositoryImpl`: Implementa RecetaRepository
  - `LocalStorageRepositoryImpl`: Implementa LocalStorageRepository

### 3. **Presentation Layer (Presentación)**
Capa de interfaz de usuario.

- **Pages**: Pantallas completas de la aplicación
  - `HomePage`: Página principal con navegación
  - `RecetasPage`: Lista de recetas
  - `FavoritosPage`: Recetas favoritas
  - `ListaComprasPage`: Lista de compras
  - `RecetaDetallePage`: Detalle de una receta

- **Widgets**: Componentes reutilizables (para desarrollo futuro)

### 4. **Core Layer (Núcleo)**
Configuración y utilidades globales.

- **Dependency Injection**: Gestión centralizada de dependencias
  - Inicializa todos los data sources
  - Crea instancias de repositorios
  - Proporciona casos de uso a toda la aplicación

## 🔄 Flujo de Datos

```
UI (Presentation) 
    ↓ solicita
Use Cases (Domain)
    ↓ usa
Repository Interface (Domain)
    ↓ implementado por
Repository Implementation (Infrastructure)
    ↓ usa
Data Sources (Infrastructure)
    ↓ accede a
API / Database
```

## ✨ Ventajas de esta Arquitectura

1. **Separación de responsabilidades**: Cada capa tiene un propósito específico
2. **Testeable**: Fácil de testear cada capa de forma independiente
3. **Mantenible**: Cambios en una capa no afectan a las demás
4. **Escalable**: Fácil agregar nuevas funcionalidades
5. **Independencia de frameworks**: El dominio no depende de Flutter
6. **Inversión de dependencias**: Las capas externas dependen de las internas

## 🔧 Inyección de Dependencias

El archivo `dependency_injection.dart` centraliza la creación de todas las instancias:

```dart
// Uso en cualquier página
final recetas = await DependencyInjection.getRecetasUseCase.execute();
```

## 📚 Principios SOLID Aplicados

- **S**ingle Responsibility: Cada clase tiene una única responsabilidad
- **O**pen/Closed: Abierto a extensión, cerrado a modificación
- **L**iskov Substitution: Las implementaciones pueden sustituir interfaces
- **I**nterface Segregation: Interfaces específicas y pequeñas
- **D**ependency Inversion: Dependencias hacia abstracciones

## 🚀 Cómo Usar

1. La aplicación se inicializa en `main.dart`
2. Se inicializan las dependencias con `DependencyInjection.initialize()`
3. Las páginas acceden a los casos de uso a través de `DependencyInjection`
4. Los casos de uso ejecutan la lógica de negocio
5. Los repositorios gestionan el acceso a datos

## 🔮 Mejoras Futuras

- [ ] Agregar manejo de estados (BLoC, Provider, Riverpod)
- [ ] Implementar manejo de errores centralizado
- [ ] Agregar logging y analytics
- [ ] Implementar caché de datos
- [ ] Agregar tests unitarios y de integración
- [ ] Crear widgets reutilizables en presentation/widgets
