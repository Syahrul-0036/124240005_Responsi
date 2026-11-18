import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Helper sederhana untuk membuat database dan menjalankan operasi akun.
class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'rick_morty_explorer.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
        await _createWishlistTable(database);
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createWishlistTable(database);
        }
      },
    );
    return _database!;
  }

  Future<void> _createWishlistTable(Database database) {
    return database.execute('''
      CREATE TABLE wishlist_products (
        product_id INTEGER PRIMARY KEY,
        product_json TEXT NOT NULL
      )
    ''');
  }

  // Memastikan nama pengguna belum pernah didaftarkan.
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Menambahkan akun baru; batas UNIQUE di database juga mencegah duplikasi.
  Future<void> registerUser(String username, String password) async {
    final db = await database;
    await db.insert('users', {'username': username, 'password': password});
  }

  // Memeriksa kecocokan nama pengguna dan kata sandi.
  Future<bool> validateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
