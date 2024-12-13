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
      version: 3,
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
        await db.execute(''' 
          CREATE TABLE bookings_orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tableNumber INTEGER,
            date TEXT,
            time TEXT,
            restaurantName TEXT,
            restaurantImage TEXT,
            orderDetails TEXT,
            totalAmount REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(''' 
            CREATE TABLE bookings_orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tableNumber INTEGER,
              date TEXT,
              time TEXT,
              restaurantName TEXT,
              restaurantImage TEXT,
              orderDetails TEXT,
              totalAmount REAL
            )
          ''');
        }
      },
    );
  }

  Future<int> insertBookingOrder(Map<String, dynamic> bookingOrder) async {
    final db = await database;
    return await db.insert('bookings_orders', bookingOrder);
  }

  Future<int> updateBookingOrder(Map<String, dynamic> bookingOrder) async {
    final db = await database;
    return await db.update(
      'bookings_orders',
      bookingOrder,
      where: 'id = ?',
      whereArgs: [bookingOrder['id']],
    );
  }

  Future<List<Map<String, dynamic>>> getBookingsOrders() async {
    final db = await database;
    return await db.query('bookings_orders');
  }

  Future<void> deleteBookingOrder(int id) async {
    final db = await database;
    await db.delete('bookings_orders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllBookingOrders() async {
    final db = await database;
    await db.delete('bookings_orders');
  }
}