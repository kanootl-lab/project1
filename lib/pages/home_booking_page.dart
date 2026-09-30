import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/database_helper.dart';
import 'add_edit_booking_page.dart';
import 'admin_page.dart';

class HomeBookingPage extends StatefulWidget {
  const HomeBookingPage({super.key});

  @override
  State<HomeBookingPage> createState() => _HomeBookingPageState();
}

class _HomeBookingPageState extends State<HomeBookingPage> {
  // ฟังก์ชันแสดง Dialog ยืนยันการลบรายการจอง
  Future<bool> _showDeleteDialog(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบรายการจองนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseHelper().deleteBooking(id);
              if (mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  // ฟังก์ชันสำหรับตรวจรหัสผ่านก่อนเข้าหน้า Admin
  void _navigateToAdminPage() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.blueGrey),
            SizedBox(width: 8),
            Text('ยืนยันสิทธิ์ Admin'),
          ],
        ),
        content: TextField(
          controller: passwordController,
          obscureText: true, // ปิดบังรหัสผ่านด้วยจุดดำ
          keyboardType: TextInputType.number, // ช่องกรอกรหัสตัวเลข
          decoration: const InputDecoration(
            labelText: 'กรุณากรอกรหัสผ่าน Admin',
            hintText: 'ใส่รหัส เช่น 1234',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800),
            onPressed: () async {
              // *** สามารถเปลี่ยนรหัสผ่าน Admin ได้ที่นี่ (ปัจจุบันคือ 1234) ***
              if (passwordController.text == '1234') {
                Navigator.pop(context); // ปิด Dialog
                
                // เปิดไปหน้า Admin
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
                setState(() {}); // รีเฟรชหน้าหลักเมื่อกลับมา
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('รหัสผ่านไม่ถูกต้อง!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // กำหนดสีของป้ายสถานะ (Status Chip)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการจองโต๊ะอาหาร'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          // ปุ่มไอคอน Admin เรียกใช้ฟังก์ชันตรวจสอบรหัสผ่าน
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'จัดการร้านค้า (Admin)',
            onPressed: _navigateToAdminPage,
          ),
        ],
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: DatabaseHelper().getBookings(), // ดึงข้อมูลรายการจองจาก SQLite
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ยังไม่มีรายการจอง',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final bookings = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = bookings[index];
                  return Dismissible(
                    key: Key(item.id.toString()),
                    background: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // ปัดขวา -> เข้าสู่หน้าแก้ไขข้อมูลการจอง
                        bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditBookingPage(booking: item),
                          ),
                        );
                        if (updated == true) {
                          setState(() {}); // รีเฟรชข้อมูลเมื่ออัปเดตเรียบร้อย
                        }
                        return false;
                      } else {
                        // ปัดซ้าย -> ยืนยันการลบ
                        bool isDeleted = await _showDeleteDialog(item.id!);
                        if (isDeleted) {
                          setState(() {}); // รีเฟรชข้อมูลเมื่อลบเรียบร้อย
                        }
                        return isDeleted;
                      }
                    },
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          item.restaurantName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ผู้จอง: ${item.customerName} (${item.partySize} ท่าน)\n'
                          'วันที่: ${item.date} | เวลา: ${item.time} น.\n'
                          'เบอร์โทร: ${item.phone}',
                        ),
                        trailing: Chip(
                          label: Text(
                            item.status,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(item.status),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () async {
          bool? added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditBookingPage(),
            ),
          );
          if (added == true) {
            setState(() {}); // รีเฟรชข้อมูลเมื่อเพิ่มการจองใหม่สำเร็จ
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}