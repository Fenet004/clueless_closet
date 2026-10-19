import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/clothing_item.dart';
import '../models/outfit_history.dart';
import '../models/saved_outfit.dart';

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
      version: 4,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
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

    await db.execute(
      '''
      CREATE TABLE favorite_outfits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topId INTEGER NOT NULL,
        bottomId INTEGER NOT NULL,
        shoeId INTEGER NOT NULL,
        score INTEGER NOT NULL

        FOREIGN KEY (topId)
          REFERENCES clothing(id)
          ON DELETE CASCADE,

        FOREIGN KEY (bottomId)
          REFERENCES clothing(id)
          ON DELETE CASCADE
        
        FOREIGN KEY (shoeId)
          REFERENCES clothing(id)
          ON DELETE CASCADE
      )
      '''
    );

    await db.execute(
      '''
      CREATE TABLE outfit_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topId INTEGER NOT NULL,
        bottomId INTEGER NOT NULL,
        shoeId INTEGER NOT NULL,
        score INTEGER NOT NULL,
        wornAt TEXT NOT NULL,

        FOREIGN KEY (topId)
          REFERENCES clothing(id)
          ON DELETE CASCADE,
        
        FOREIGN KEY (bottomId)
          REFERENCES clothing(id)
          ON DELETE CASCADE
        
        FOREIGN KEY (shoeId)
          REFERENCES clothing(id)
          ON DELETE CASCADE
      )
      '''
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

    if (oldVersion < 3) {
      await db.execute(
        '''
        CREATE TABLE favorite_outfits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          topId INTEGER NOT NULL,
          bottomId INTEGER NOT NULL,
          shoeId INTEGER NOT NULL,
          score INTEGER NOT NULL
        )
        '''
      );
    }

    if (oldVersion < 4) {
      await db.execute(
        '''
        CREATE TABLE outfit_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          topId INTEGER NOT NULL,
          bottomId INTEGER NOT NULL,
          shoeId INTEGER NOT NULL,
          score INTEGER NOT NULL,
          wornAt TEXT NOT NULL,

          FOREIGN KEY (topId)
            REFERENCES clothing(id)
            ON DELETE CASCADE,

          FOREIGN KEY (bottomId)
            REFERENCES clothing(id)
            ON DELETE CASCADE,

          FOREIGN KEY (shoeId)
            REFERENCES clothing(id)
            ON DELETE CASCADE
        )
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

  Future<SavedOutfit> insertFavoriteOutfit(SavedOutfit outfit) async {
    final db = await database;

    final map = outfit.toMap();
    map.remove('id');

    final id = await db.insert('favorite_outfits', map);

    return outfit.copyWith(id: id);
  }

  Future<List<SavedOutfit>> getFavoriteOutfits() async {
    final db = await database;

    final maps = await db.query(
      'favorite_outfits',
      orderBy: 'id DESC',
    );

    return maps
        .map(
          (map) => SavedOutfit.fromMap(map),
        )
        .toList();
  }

  Future<void> deleteFavoriteOutfit(int id) async {
    final db = await database;

    await db.delete(
      'favorite_outfits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isFavoriteOutfit(int topId, int bottomId, int shoeId) async {
    final db = await database;

    final result = await db.query(
      'favorite_outfits',
      where: 'topId = ? AND bottomId = ? AND shoeId = ?',
      whereArgs: [topId, bottomId, shoeId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<OutfitHistory> insertOutfitHistory(OutfitHistory history) async {
    final db = await database;

    final map = history.toMap();
    map.remove('id');

    final id = await db.insert(
      'outfit_history',
      map,
    );

    return history.copyWith(id: id);
  }

  Future<List<OutfitHistory>> getOutfitHistory() async {
    final db = await database;

    final maps = await db.query(
      'outfit_history',
      orderBy: 'wornAt DESC',
    );

    return maps
        .map(
          (map) => OutfitHistory.fromMap(map),
        )
        .toList();
  }

  Future<void> deleteOutfitHistory(int id) async {
    final db = await database;

    await db.delete(
      'outfit_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}