import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/clothing_item.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'clueless_closet.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute(
      ''' 
      CREATE TABLE clothing (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        color TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        isAssetImage INTEGER NOT NULL
      )
      ''',
    );
  }

  Future<ClothingItem> insertClothing(ClothingItem item) async {
    final db = await database;
    final map = item.toMap();

    map.remove('id');

    final id = await db.insert('clothing', map);

    return item.copyWith(id: id);
  }

  Future<List<ClothingItem>> getAllClothing() async {
    final db = await database;

    final maps = await db.query(
      'clothing',
      orderBy: 'id ASC',
    );

    return maps
        .map(
          (map) => ClothingItem.fromMap(map),
        )
        .toList();
  }

  Future<void> updateClothing(ClothingItem item) async {
    final db = await database;

    await db.update(
      'clothing',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteClothing(int id) async {
    final db = await database;

    await db.delete(
      'clothing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}