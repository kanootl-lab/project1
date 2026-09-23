import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<String> fetchRandomSpecialDish() async {
    const url = 'https://foodish-api.com/api/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image'];
      } else {
        throw Exception('Failed to load dish image');
      }
    } catch (e) {
      return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836';
    }
  }
}