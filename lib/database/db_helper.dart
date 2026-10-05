import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/persona.dart';

/// Clase Singleton para la administración de la base de datos SQLite
class DatabaseHelper {
  static const String _dbName = 'personas_database.db';
  static const int _dbVersion = 1;
  static const String tableName = 'personas';

  // Constructor privado para patrón Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Obtiene la instancia de la base de datos (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos en la ruta adecuada del dispositivo
  Future<Database> _initDatabase() async {
    // Obtiene el directorio de documentos de la aplicación
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  /// Crea la tabla 'personas' cuando se crea la base de datos por primera vez
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        foto TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  /// Inserta una nueva persona en la base de datos
  Future<int> insertPersona(Persona persona) async {
    final db = await database;
    return await db.insert(
      tableName,
      persona.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene la lista completa de personas ordenadas por id descendente (las más recientes primero)
  Future<List<Persona>> getPersonas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Persona.fromMap(maps[i]);
    });
  }

  /// Busca personas por coincidencia en el nombre
  Future<List<Persona>> searchPersonas(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'nombre LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Persona.fromMap(maps[i]);
    });
  }

  /// Actualiza los datos de una persona existente
  Future<int> updatePersona(Persona persona) async {
    final db = await database;
    return await db.update(
      tableName,
      persona.toMap(),
      where: 'id = ?',
      whereArgs: [persona.id],
    );
  }

  /// Elimina una persona por su ID y opcionalmente borra el archivo de imagen local
  Future<int> deletePersona(int id, String? fotoPath) async {
    final db = await database;

    // Eliminar archivo de imagen del almacenamiento si existe
    if (fotoPath != null && fotoPath.isNotEmpty) {
      try {
        final file = File(fotoPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignorar error si no se pudo eliminar el archivo físico
      }
    }

    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
