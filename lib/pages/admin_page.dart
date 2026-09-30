import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../services/database_helper.dart';
import 'add_edit_booking_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<BookingModel> _allBookings = [];
  List<BookingModel> _filteredBookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final bookings = await _dbHelper.getBookings();
    setState(() {
      _allBookings = bookings;
      _applyFilter(_selectedFilter);
      _isLoading = false;
    });
  }

  void _applyFilter(String status) {
    _selectedFilter = status;
    if (status == 'All') {
      _filteredBookings = _allBookings;
    } else {
      _filteredBookings = _allBookings.where((b) => b.status == status).toList();
    }
  }

  Future<void> _updateStatus(BookingModel booking, String newStatus) async {
    BookingModel updatedBooking = BookingModel(
      id: booking.id,
      customerName: booking.customerName,
      phone: booking.phone,
      restaurantName: booking.restaurantName,
      date: booking.date,
      time: booking.time,
      partySize: booking.partySize,
      rating: booking.rating,
      status: newStatus,
    );

    await _dbHelper.updateBooking(booking.id!, updatedBooking);
    _loadBookings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('อัปเดตสถานะเป็น $newStatus สำเร็จ'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteBooking(int id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ยืนยันการลบ'),
            content: const Text('คุณต้องการลบข้อมูลการจองนี้ใช่หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ลบ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _dbHelper.deleteBooking(id);
      _loadBookings();
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการการจอง (Admin)'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // ตัวกรองสถานะ (Filter Bar)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'].map((status) {
                  bool isSelected = _selectedFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(status),
                      selectedColor: Colors.deepOrange.shade100,
                      onSelected: (bool selected) {
                        setState(() {
                          _applyFilter(status);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // รายการจอง (Booking List)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? const Center(child: Text('ไม่มีข้อมูลการจอง'))
                    : ListView.builder(
                        itemCount: _filteredBookings.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final booking = _filteredBookings[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          booking.restaurantName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(booking.status).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          booking.status,
                                          style: TextStyle(
                                            color: _getStatusColor(booking.status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Text('ชื่อลูกค้า: ${booking.customerName} (${booking.phone})'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text('วันที่: ${booking.date}  |  เวลา: ${booking.time} น.'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text('จำนวน: ${booking.partySize} ท่าน'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // เมนูปรับเปลี่ยนสถานะ และปุ่มแก้ไข/ลบ
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DropdownButton<String>(
                                        value: booking.status,
                                        underline: const SizedBox(),
                                        items: const [
                                          DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                          DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                                          DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                                          DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                                        ],
                                        onChanged: (newStatus) {
                                          if (newStatus != null) {
                                            _updateStatus(booking, newStatus);
                                          }
                                        },
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () async {
                                              bool? updated = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddEditBookingPage(booking: booking),
                                                ),
                                              );
                                              if (updated == true) {
                                                _loadBookings();
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteBooking(booking.id!),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}