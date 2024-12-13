import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'booking.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version for the new schema
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tableNumber INTEGER,
            date TEXT,
            time TEXT,
            restaurantName TEXT,
            restaurantImage TEXT
          )
        ''');
        await db.execute(''' 
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tableNumber INTEGER,
            restaurantName TEXT,
            orderDetails TEXT,
            totalAmount REAL,
            date TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(''' 
            CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tableNumber INTEGER,
              restaurantName TEXT,
              orderDetails TEXT,
              totalAmount REAL,
              date TEXT
            )
          ''');
        }
      },
    );
  }

  Future<int> insertBooking(Map<String, dynamic> booking) async {
    final db = await database;
    return await db.insert('bookings', booking);
  }

  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    return await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    final db = await database;
    return await db.query('bookings');
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders');
  }

  Future<void> deleteBooking(int id) async {
    final db = await database;
    await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteOrder(int id) async {
    final db = await database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> deleteAllOrders() async {
    final db = await database;
    await db.delete('orders');
  }
}



