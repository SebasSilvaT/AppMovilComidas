import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'receta.dart';
import 'dart:async';

class DatabaseHelper {
  static Future<void> initializeDatabase() async {
    // No necesitamos inicialización especial para Android
    await getDatabasesPath(); // Esto asegura que el sistema de base de datos está listo
  }
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

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
            receta_id INTEGER
          )
        ''');
        
        await db.execute('''
          CREATE TABLE lista_compras (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receta_id INTEGER,
            ingrediente_nombre TEXT,
            ingrediente_cantidad TEXT,
            fecha_agregado TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> agregarFavorito(int recetaId) async {
    final db = await database;
    await db.insert(
      'favoritos',
      {'receta_id': recetaId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminarFavorito(int recetaId) async {
    final db = await database;
    await db.delete(
      'favoritos',
      where: 'receta_id = ?',
      whereArgs: [recetaId],
    );
  }

  Future<bool> esFavorito(int recetaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favoritos',
      where: 'receta_id = ?',
      whereArgs: [recetaId],
    );
    return maps.isNotEmpty;
  }

  Future<void> agregarIngredienteALista(
    int recetaId,
    String nombreIngrediente,
    String cantidadIngrediente,
  ) async {
    final db = await database;
    await db.insert(
      'lista_compras',
      {
        'receta_id': recetaId,
        'ingrediente_nombre': nombreIngrediente,
        'ingrediente_cantidad': cantidadIngrediente,
        'fecha_agregado': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminarIngredienteDeLista(
    int recetaId,
    String nombreIngrediente,
  ) async {
    final db = await database;
    await db.delete(
      'lista_compras',
      where: 'receta_id = ? AND ingrediente_nombre = ?',
      whereArgs: [recetaId, nombreIngrediente],
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
}