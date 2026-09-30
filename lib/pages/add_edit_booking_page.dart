import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../services/database_helper.dart';

class AddEditBookingPage extends StatefulWidget {
  final BookingModel? booking;

  const AddEditBookingPage({super.key, this.booking});

  @override
  State<AddEditBookingPage> createState() => _AddEditBookingPageState();
}

class _AddEditBookingPageState extends State<AddEditBookingPage> {
  final _formKey = GlobalKey<FormState>();

  late String _customerName;
  late String _phone;
  String _restaurantName = 'ร้านมุมการ์เด้น (Moom Garden)';
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '12:00';
  int _partySize = 1;
  double _rating = 5.0;
  String _status = 'Pending'; // ค่าเริ่มต้นสำหรับการจองใหม่

  final List<String> _restaurantList = [
    'ร้านมุมการ์เด้น (Moom Garden)',
    'Sizzler (ซิซซ์เล่อร์)',
    'MK Restaurants',
    'Shabu Shi (ชาบูชิ)',
    'Bar B Q Plaza (บาร์บีคิวพลาซ่า)',
    'Greyhound Café',
    'Katsuya (คัตสึยะ)',
  ];

  final List<String> _timeList = ['11:00', '12:00', '13:00', '17:00', '18:00', '19:00', '20:00'];

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _customerName = widget.booking!.customerName;
      _phone = widget.booking!.phone;
      
      String fullResName = widget.booking!.restaurantName;
      for (var res in _restaurantList) {
        if (fullResName.contains(res)) {
          _restaurantName = res;
          break;
        }
      }

      try {
        _selectedDate = DateTime.parse(widget.booking!.date);
      } catch (_) {}

      _selectedTime = widget.booking!.time;
      _partySize = widget.booking!.partySize;
      _rating = widget.booking!.rating;
      _status = widget.booking!.status; // ดึงสถานะเดิมมาแสดงแบบ Read-only
    } else {
      _customerName = '';
      _phone = '';
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final dbHelper = DatabaseHelper();

      var settings = await dbHelper.getRestaurantSettings(_restaurantName);
      bool isOpen = (settings?['isOpen'] ?? 1) == 1;
      int maxCapacity = settings?['maxCapacity'] ?? 20;

      if (!isOpen) {
        _showAlertDialog('ร้านปิดรับจอง', 'ขออภัย ขณะนี้ทางร้านปิดรับการจองชั่วคราว');
        return;
      }

      int currentBooked = await dbHelper.getTotalBookedSeats(_restaurantName, formattedDate);
      
      if (widget.booking != null && widget.booking!.status != 'Cancelled') {
        currentBooked -= widget.booking!.partySize;
      }

      int remainingSeats = maxCapacity - currentBooked;

      if (_status != 'Cancelled' && _partySize > remainingSeats) {
        if (remainingSeats <= 0) {
          _showAlertDialog('ที่นั่งเต็มแล้ว', 'ขออภัย ที่นั่งในวันที่เลือกถูกจองเต็มแล้ว');
        } else {
          _showAlertDialog('ที่นั่งไม่พอ', 'ขออภัย เหลือที่นั่งว่างเพียง $remainingSeats ท่าน ไม่พอสำหรับจำนวนที่ระบุ ($_partySize ท่าน)');
        }
        return;
      }

      BookingModel newBooking = BookingModel(
        id: widget.booking?.id,
        customerName: _customerName,
        phone: _phone,
        restaurantName: _restaurantName,
        date: formattedDate,
        time: _selectedTime,
        partySize: _partySize,
        rating: _rating,
        status: _status, // ใช้สถานะเดิม (หรือ Pending สำหรับการจองใหม่)
      );

      if (widget.booking == null) {
        await dbHelper.addBooking(newBooking);
      } else {
        await dbHelper.updateBooking(widget.booking!.id!, newBooking);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.booking == null ? 'บันทึกการจองสำเร็จ!' : 'อัปเดตข้อมูลการจองสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
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
        title: Text(widget.booking == null ? 'เพิ่มการจองโต๊ะ' : 'แก้ไขการจองโต๊ะ'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _customerName,
                decoration: const InputDecoration(
                  labelText: 'ชื่อผู้จอง',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกชื่อผู้จอง' : null,
                onSaved: (val) => _customerName = val!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
                onSaved: (val) => _phone = val!,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _restaurantName,
                decoration: const InputDecoration(
                  labelText: 'ร้านอาหาร',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
                items: _restaurantList.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => _restaurantName = val!),
              ),
              const SizedBox(height: 16),

              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today, color: Colors.deepOrange),
                title: Text('วันที่จอง: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedTime,
                decoration: const InputDecoration(
                  labelText: 'เวลาที่จอง',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                items: _timeList.map((t) => DropdownMenuItem(value: t, child: Text('$t น.'))).toList(),
                onChanged: (val) => setState(() => _selectedTime = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Text('จำนวน (ท่าน):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('$_partySize', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _partySize++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔒 ส่วนแสดงสถานะการจองแบบ Read-only (ผู้ใช้ทั่วไปแก้ไขไม่ได้ ต้องรอแอดมินเปลี่ยน)
              if (widget.booking != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Text(
                        'สถานะการจอง:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          _status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: _getStatusColor(_status),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '* สถานะการจองจะได้รับการอัปเดตโดยผู้ดูแลระบบ (Admin) เท่านั้น',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.booking == null ? 'ยืนยันการจอง' : 'บันทึกการแก้ไข',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}