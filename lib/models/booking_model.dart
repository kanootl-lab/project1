class BookingModel {
  final int? id;
  final String customerName;
  final String phone;
  final String restaurantName;
  final String date;
  final String time;
  final int partySize;
  final double rating;
  final String status;

  BookingModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.restaurantName,
    required this.date,
    required this.time,
    required this.partySize,
    this.rating = 5.0,
    this.status = 'Pending',
  });

  // แปลงจาก Map เป็น BookingModel (ใช้ตอนดึงจาก Database)
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      partySize: map['partySize'] ?? 1,
      rating: (map['rating'] ?? 5.0).toDouble(),
      status: map['status'] ?? 'Pending',
    );
  }

  // แปลงจาก BookingModel เป็น Map (ใช้ตอนบันทึกลง Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'restaurantName': restaurantName,
      'date': date,
      'time': time,
      'partySize': partySize,
      'rating': rating,
      'status': status,
    };
  }
}