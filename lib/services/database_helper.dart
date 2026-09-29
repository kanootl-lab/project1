import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'restaurant_booking.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bookings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerName TEXT,
            phone TEXT,
            restaurantName TEXT,
            date TEXT,
            time TEXT,
            partySize INTEGER,
            rating REAL,
            status TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE restaurants(
            name TEXT PRIMARY KEY,
            maxCapacity INTEGER,
            isOpen INTEGER
          )
        ''');

        List<String> defaultRestaurants = [
          'ร้านมุมการ์เด้น (Moom Garden)',
          'Sizzler (ซิซซ์เล่อร์)',
          'MK Restaurants',
          'Shabu Shi (ชาบูชิ)',
          'Bar B Q Plaza (บาร์บีคิวพลาซ่า)',
          'Greyhound Café',
          'Katsuya (คัตสึยะ)',
        ];

        for (var name in defaultRestaurants) {
          await db.insert('restaurants', {
            'name': name,
            'maxCapacity': 20,
            'isOpen': 1,
          });
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE bookings ADD COLUMN status TEXT DEFAULT 'Pending'");
        }
      },
    );
  }

  Future<Map<String, dynamic>?> getRestaurantSettings(String restaurantName) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'restaurants',
      where: 'name = ?',
      whereArgs: [restaurantName],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> updateRestaurantSettings(String name, int maxCapacity, bool isOpen) async {
    final db = await database;
    await db.update(
      'restaurants',
      {
        'maxCapacity': maxCapacity,
        'isOpen': isOpen ? 1 : 0,
      },
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<int> getTotalBookedSeats(String restaurantName, String date) async {
    final db = await database;
    var result = await db.rawQuery(
      "SELECT SUM(partySize) as total FROM bookings WHERE restaurantName LIKE ? AND date = ? AND status != 'Cancelled'",
      ['$restaurantName%', date],
    );
    return result.first['total'] != null ? result.first['total'] as int : 0;
  }

  Future<List<BookingModel>> getBookings() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('bookings', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => BookingModel.fromMap(maps[i]));
  }

  Future<int> addBooking(BookingModel booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<int> updateBooking(int id, BookingModel booking) async {
    final db = await database;
    return await db.update('bookings', booking.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBookingStatus(int id, String newStatus) async {
    final db = await database;
    return await db.update(
      'bookings',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }
}