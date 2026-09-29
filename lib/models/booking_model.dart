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
    required this.rating,
    this.status = 'Pending',
  });

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

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      customerName: map['customerName'],
      phone: map['phone'],
      restaurantName: map['restaurantName'],
      date: map['date'],
      time: map['time'],
      partySize: map['partySize'],
      rating: map['rating'],
      status: map['status'] ?? 'Pending',
    );
  }
}