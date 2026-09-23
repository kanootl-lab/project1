import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class DatabaseHelper {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('restaurant_bookings');

  // ดึงข้อมูล Realtime
  Stream<QuerySnapshot> getBookingsStream() {
    return _collection.snapshots();
  }

  // เพิ่มข้อมูลการจอง (Create)
  Future<DocumentReference> addBooking(BookingModel booking) async {
    return await _collection.add(booking.toJson());
  }

  // แก้ไขข้อมูลการจอง (Update)
  Future<void> updateBooking(String id, BookingModel booking) async {
    return await _collection.doc(id).update(booking.toJson());
  }

  // ลบข้อมูลการจอง (Delete)
  Future<void> deleteBooking(String id) async {
    return await _collection.doc(id).delete();
  }
}