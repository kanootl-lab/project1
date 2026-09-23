import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, String>> fetchRandomSpecialDish() async {
    const String url = 'https://www.themealdb.com/api/json/v1/1/random.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meal = data['meals'][0];

        return {
          'name': meal['strMeal'] ?? 'ไม่ทราบชื่อเมนู',
          'category': meal['strCategory'] ?? 'ทั่วไป',
          'area': meal['strArea'] ?? 'ไม่ระบุ',
          'image': '${meal['strMealThumb']}?t=${DateTime.now().millisecondsSinceEpoch}',
          'instructions': meal['strInstructions'] ?? 'ไม่มีคำอธิบาย',
        };
      } else {
        throw Exception('Failed to load dish data');
      }
    } catch (e) {
      return {
        'name': 'เมนูแนะนำสำรอง',
        'category': 'อาหารจานเดียว',
        'area': 'นานาชาติ',
        'image': 'https://picsum.photos/500/300?random=${DateTime.now().millisecondsSinceEpoch}',
        'instructions': 'เกิดข้อผิดพลาดในการโหลดข้อมูลจาก Server กรุณากดลองใหม่อีกครั้ง',
      };
    }
  }
}