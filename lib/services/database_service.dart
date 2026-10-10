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
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
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
        isAssetImage INTEGER NOT NULL,
        style TEXT NOT NULL,
        occasion TEXT NOT NULL,
        season TEXT NOT NULL
      )
      ''',
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        ''' 
          ALTER TABLE clothing
          ADD COLUMN style TEXT NOT NULL
          DEFAULT 'Casual'
        ''',
      );

      await db.execute(
        ''' 
          ALTER TABLE clothing
          ADD COLUMN occasion TEXT NOT NULL
          DEFAULT 'Everyday'
        ''',
      );

      await db.execute(
        '''  
          ALTER TABLE clothing
          ADD COLUMN season TEXT NOT NULL
          DEFAULT 'All'
        ''',
      );
    }
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