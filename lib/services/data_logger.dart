import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataLogger {
  static final DataLogger _instance = DataLogger._internal();
  factory DataLogger() => _instance;
  DataLogger._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'obd_datalogger.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pid_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            pid_description TEXT,
            pid_value TEXT,
            pid_unit TEXT
          )
        ''');
      },
    );
  }

  Future<void> logPid({
    required String description,
    required String value,
    required String unit,
  }) async {
    final db = await database;
    await db.insert(
      'pid_logs',
      {
        'pid_description': description,
        'pid_value': value,
        'pid_unit': unit,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPidLogs(String pidDescription) async {
    final db = await database;
    return await db.query(
      'pid_logs',
      where: 'pid_description = ?',
      whereArgs: [pidDescription],
      orderBy: 'timestamp DESC',
      limit: 100, // Limit to the latest 100 for performance
    );
  }
}
