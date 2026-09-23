class BookingModel {
  String? id;
  String customerName;
  String phone;
  String restaurantName;
  String date;
  String time;
  int partySize;
  double rating;

  BookingModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.restaurantName,
    required this.date,
    required this.time,
    required this.partySize,
    this.rating = 5.0,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json, String docId) {
    return BookingModel(
      id: docId,
      customerName: json['customerName'] ?? '',
      phone: json['phone'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      partySize: json['partySize'] ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phone': phone,
      'restaurantName': restaurantName,
      'date': date,
      'time': time,
      'partySize': partySize,
      'rating': rating,
    };
  }
}