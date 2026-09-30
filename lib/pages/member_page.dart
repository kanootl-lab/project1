import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final member = MemberModel(
      name: 'นาย คณุตม์ ลาวัณย์วิสุทธิ์',
      studentId: '6721652005',
      role: 'Full Stack Developer (Solo Project)',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมาชิกผู้พัฒนา'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: isWide ? 450 : double.infinity,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepOrange,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('รหัสนิสิต: ${member.studentId}'),
                        const SizedBox(height: 4),
                        Text(
                          'ตำแหน่ง: ${member.role}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}