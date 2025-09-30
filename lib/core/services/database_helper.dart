import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kami_geoloc.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE positions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timestamp TEXT NOT NULL
)
''');
  }

  Future<void> insertPosition(Map<String, dynamic> position) async {
    final db = await instance.database;
    await db.insert('positions', position);
  }

  Future<List<Map<String, dynamic>>> getPositions() async {
    final db = await instance.database;
    return await db.query('positions', orderBy: 'timestamp ASC');
  }

  Future<void> clearPositions() async {
    final db = await instance.database;
    await db.delete('positions');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
