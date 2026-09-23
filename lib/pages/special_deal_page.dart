import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SpecialDealPage extends StatefulWidget {
  const SpecialDealPage({super.key});

  @override
  State<SpecialDealPage> createState() => _SpecialDealPageState();
}

class _SpecialDealPageState extends State<SpecialDealPage> {
  final ApiService _apiService = ApiService();
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _apiService.fetchRandomSpecialDish();
  }

  void _refresh() {
    setState(() {
      _imageUrlFuture = _apiService.fetchRandomSpecialDish();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<String>(
                future: _imageUrlFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        snapshot.data!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return const Text('ไม่พบข้อมูล');
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('สุ่มเมนูแนะนำใหม่'),
              )
            ],
          ),
        ),
      ),
    );
  }
}