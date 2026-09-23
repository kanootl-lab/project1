import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SpecialDealPage extends StatefulWidget {
  const SpecialDealPage({super.key});

  @override
  State<SpecialDealPage> createState() => _SpecialDealPageState();
}

class _SpecialDealPageState extends State<SpecialDealPage> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, String>> _mealDataFuture;

  @override
  void initState() {
    super.initState();
    _mealDataFuture = _apiService.fetchRandomSpecialDish();
  }

  void _refresh() {
    setState(() {
      _mealDataFuture = _apiService.fetchRandomSpecialDish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เมนูพิเศษประจำวัน (External API)'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _mealDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final meal = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. รูปภาพอาหาร
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      meal['image']!,
                      key: ValueKey(meal['image']),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 250,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. ชื่อเมนูอาหาร
                  Text(
                    meal['name']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // 3. หมวดหมู่ และสัญชาติอาหาร
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(meal['category']!),
                        backgroundColor: Colors.orange.shade50,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.public, size: 16),
                        label: Text(meal['area']!),
                        backgroundColor: Colors.orange.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. ปุ่มสุ่มเมนูใหม่
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('สุ่มเมนูแนะนำใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. รายละเอียด / วิธีทำ
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'คำอธิบาย / วิธีทำ:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meal['instructions']!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('ไม่พบข้อมูล'));
        },
      ),
    );
  }
}