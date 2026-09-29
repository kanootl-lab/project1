import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/database_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<String> _restaurantList = [
    'ร้านมุมการ์เด้น (Moom Garden)',
    'Sizzler (ซิซซ์เล่อร์)',
    'MK Restaurants',
    'Shabu Shi (ชาบูชิ)',
    'Bar B Q Plaza (บาร์บีคิวพลาซ่า)',
    'Greyhound Café',
    'Katsuya (คัตสึยะ)',
  ];

  String _selectedRestaurant = 'ร้านมุมการ์เด้น (Moom Garden)';
  int _maxCapacity = 20;
  bool _isOpen = true;
  bool _isLoading = true;
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    var settings = await DatabaseHelper().getRestaurantSettings(_selectedRestaurant);
    if (settings != null) {
      _maxCapacity = settings['maxCapacity'] ?? 20;
      _isOpen = (settings['isOpen'] ?? 1) == 1;
    }
    _bookings = await DatabaseHelper().getBookings();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper().updateRestaurantSettings(_selectedRestaurant, _maxCapacity, _isOpen);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตการตั้งค่าร้านค้าเรียบร้อย!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _changeStatus(int id, String status) async {
    await DatabaseHelper().updateBookingStatus(id, status);
    _loadData();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin - จัดการร้านค้าและสถานะ'),
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'ตั้งค่าโควตาร้าน'),
              Tab(icon: Icon(Icons.list_alt), text: 'รายการการจอง'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab 1: การตั้งค่าโควตา
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('เลือกร้านค้าที่ต้องการจัดการ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedRestaurant,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _restaurantList.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedRestaurant = val);
                              _loadData();
                            }
                          },
                        ),
                        const Divider(height: 32),
                        SwitchListTile(
                          title: const Text('สถานะรับจองโต๊ะ', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_isOpen ? 'เปิดรับจองปกติ' : 'ปิดรับจองชั่วคราว (เต็ม/ร้านปิด)'),
                          value: _isOpen,
                          activeColor: Colors.green,
                          onChanged: (val) => setState(() => _isOpen = val),
                        ),
                        const SizedBox(height: 16),
                        const Text('โควตาความจุสูงสุด (Max Capacity):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: _maxCapacity > 0 ? () => setState(() => _maxCapacity -= 5) : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Expanded(
                              child: Text('$_maxCapacity ท่าน', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => setState(() => _maxCapacity += 5),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey.shade800,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _saveSettings,
                            icon: const Icon(Icons.save),
                            label: const Text('บันทึกการตั้งค่าร้านค้า'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: อนุมัติ/ยกเลิกสถานะการจอง
                  _bookings.isEmpty
                      ? const Center(child: Text('ยังไม่มีรายการจอง'))
                      : ListView.builder(
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final item = _bookings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text('${item.customerName} (${item.partySize} ท่าน)'),
                                subtitle: Text('${item.restaurantName}\nวันที่: ${item.date} | เวลา: ${item.time} น.'),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(item.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      backgroundColor: _getStatusColor(item.status),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (val) => _changeStatus(item.id!, val),
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(value: 'Pending', child: Text('Pending (รอยืนยัน)')),
                                        PopupMenuItem(value: 'Confirmed', child: Text('Confirmed (ยืนยันแล้ว)')),
                                        PopupMenuItem(value: 'Completed', child: Text('Completed (มาใช้บริการแล้ว)')),
                                        PopupMenuItem(value: 'Cancelled', child: Text('Cancelled (ยกเลิก)')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}