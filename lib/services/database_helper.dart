import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurant_bookings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        phone TEXT NOT NULL,
        restaurantName TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        partySize INTEGER NOT NULL,
        rating REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  // เพิ่มข้อมูลการจองใหม่
  Future<int> addBooking(BookingModel booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  // อัปเดตข้อมูลการจอง
  Future<int> updateBooking(int id, BookingModel booking) async {
    final db = await database;
    return await db.update(
      'bookings',
      booking.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ดึงข้อมูลการจองทั้งหมด
  Future<List<BookingModel>> getAllBookings() async {
    final db = await database;
    final result = await db.query('bookings', orderBy: 'id DESC');
    return result.map((json) => BookingModel.fromMap(json)).toList();
  }

  // ฟังก์ชันรองรับหน้า home_booking_page และ admin_page
  Future<List<BookingModel>> getBookings() async {
    return await getAllBookings();
  }

  // ลบข้อมูลการจอง
  Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  // ดึงการตั้งค่าร้านค้า
  Future<Map<String, dynamic>?> getRestaurantSettings(String restaurantName) async {
    return {'isOpen': 1, 'maxCapacity': 20};
  }

  // ⭐️ คำนวณจำนวนที่นั่งที่ถูกจองไปแล้ว (ไม่นับรวมทั้ง Cancelled และ Completed เพื่อคืนโควต้าที่นั่ง) ⭐️
  Future<int> getTotalBookedSeats(String restaurantName, String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(partySize) as total FROM bookings WHERE restaurantName = ? AND date = ? AND status NOT IN (?, ?)',
      [restaurantName, date, 'Cancelled', 'Completed'],
    );
    return result.first['total'] != null ? (result.first['total'] as int) : 0;
  }
}