import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../../domain/entities/ingrediente.dart';

/// Local data source for managing database operations
class LocalDataSource {
  static Future<void> initializeDatabase() async {
    await getDatabasesPath();
  }

  static final LocalDataSource _instance = LocalDataSource._internal();
  static Database? _database;

  factory LocalDataSource() => _instance;

  LocalDataSource._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'recetas_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favoritos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receta_id INTEGER UNIQUE
          )
        ''');
        
        await db.execute('''
          CREATE TABLE lista_compras (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receta_id INTEGER,
            ingrediente_nombre TEXT UNIQUE,
            ingrediente_cantidad TEXT,
            fecha_agregado TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS favoritos');
          await db.execute('DROP TABLE IF EXISTS lista_compras');
          
          await db.execute('''
            CREATE TABLE favoritos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              receta_id INTEGER UNIQUE
            )
          ''');
          
          await db.execute('''
            CREATE TABLE lista_compras (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              receta_id INTEGER,
              ingrediente_nombre TEXT UNIQUE,
              ingrediente_cantidad TEXT,
              fecha_agregado TEXT
            )
          ''');
        }
      },
      version: 2,
    );
  }

  // Favoritos operations
  Future<void> agregarFavorito(int recetaId) async {
    try {
      final db = await database;
      await db.insert(
        'favoritos',
        {'receta_id': recetaId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Favorito agregado: $recetaId');
    } catch (e) {
      print('Error al agregar favorito: $e');
      rethrow;
    }
  }

  Future<void> eliminarFavorito(int recetaId) async {
    try {
      final db = await database;
      await db.delete(
        'favoritos',
        where: 'receta_id = ?',
        whereArgs: [recetaId],
      );
      print('Favorito eliminado: $recetaId');
    } catch (e) {
      print('Error al eliminar favorito: $e');
      rethrow;
    }
  }

  Future<bool> esFavorito(int recetaId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'favoritos',
        where: 'receta_id = ?',
        whereArgs: [recetaId],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error al verificar favorito: $e');
      return false;
    }
  }

  Future<List<int>> obtenerTodosFavoritos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favoritos');
    return List<int>.from(maps.map((map) => map['receta_id'] as int));
  }

  // Lista de compras operations
  Future<void> agregarIngredientesALista(
    int recetaId,
    List<Ingrediente> ingredientes,
  ) async {
    final db = await database;
    
    for (var ingrediente in ingredientes) {
      await _agregarIngredienteALista(
        db,
        recetaId,
        ingrediente.nombre,
        ingrediente.cantidad,
      );
    }
  }

  Future<void> _agregarIngredienteALista(
    Database db,
    int recetaId,
    String nombreIngrediente,
    String cantidadIngrediente,
  ) async {
    RegExp regExp = RegExp(r'(\d+\.?\d*)\s*(.*)');
    var match = regExp.firstMatch(cantidadIngrediente);
    
    if (match != null) {
      double cantidad = double.tryParse(match.group(1) ?? '0') ?? 0;
      String unidad = match.group(2) ?? '';
      
      var existente = await db.query(
        'lista_compras',
        where: 'ingrediente_nombre = ?',
        whereArgs: [nombreIngrediente],
      );
      
      if (existente.isNotEmpty) {
        String cantidadExistente = existente.first['ingrediente_cantidad'] as String;
        var matchExistente = regExp.firstMatch(cantidadExistente);
        if (matchExistente != null) {
          double cantidadAnterior = double.tryParse(matchExistente.group(1) ?? '0') ?? 0;
          cantidad += cantidadAnterior;
        }
      }
      
      await db.insert(
        'lista_compras',
        {
          'receta_id': recetaId,
          'ingrediente_nombre': nombreIngrediente,
          'ingrediente_cantidad': '$cantidad $unidad',
          'fecha_agregado': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> eliminarIngredienteDeLista(String nombreIngrediente) async {
    final db = await database;
    await db.delete(
      'lista_compras',
      where: 'ingrediente_nombre = ?',
      whereArgs: [nombreIngrediente],
    );
  }

  Future<List<Map<String, dynamic>>> obtenerListaCompras() async {
    final db = await database;
    return await db.query('lista_compras', orderBy: 'fecha_agregado DESC');
  }

  Future<void> limpiarListaCompras() async {
    final db = await database;
    await db.delete('lista_compras');
  }

  Future<void> actualizarCantidadIngrediente(
    String nombreIngrediente,
    double nuevaCantidad,
  ) async {
    final db = await database;
    
    // Obtener el ingrediente existente para mantener la unidad
    var existente = await db.query(
      'lista_compras',
      where: 'ingrediente_nombre = ?',
      whereArgs: [nombreIngrediente],
    );
    
    if (existente.isNotEmpty) {
      String cantidadExistente = existente.first['ingrediente_cantidad'] as String;
      RegExp regExp = RegExp(r'(\d+\.?\d*)\s*(.*)');
      var match = regExp.firstMatch(cantidadExistente);
      
      String unidad = '';
      if (match != null) {
        unidad = match.group(2) ?? '';
      }
      
      await db.update(
        'lista_compras',
        {'ingrediente_cantidad': '$nuevaCantidad $unidad'},
        where: 'ingrediente_nombre = ?',
        whereArgs: [nombreIngrediente],
      );
    }
  }

  Future<void> resetDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'recetas_database.db');
    await deleteDatabase(dbPath);
    _database = null;
    await database;
  }
}
