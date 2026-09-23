import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  late String _restaurantName;
  late String _time;
  late int _partySize;
  late double _rating;

  // เทคนิคใหม่: TableCalendar Setup
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _customerName = widget.booking?.customerName ?? '';
    _phone = widget.booking?.phone ?? '';
    _restaurantName = widget.booking?.restaurantName ?? '';
    _time = widget.booking?.time ?? '18:00';
    _partySize = widget.booking?.partySize ?? 2;
    _rating = widget.booking?.rating ?? 5.0;
    _selectedDay = widget.booking != null
        ? DateFormat('yyyy-MM-dd').parse(widget.booking!.date)
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.booking != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขรายการจอง' : 'เพิ่มการจองโต๊ะ'),
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
                initialValue: _restaurantName,
                decoration: const InputDecoration(labelText: 'ชื่อร้านอาหาร', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่อร้าน' : null,
                onSaved: (val) => _restaurantName = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _customerName,
                decoration: const InputDecoration(labelText: 'ชื่อผู้จอง', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่อผู้จอง' : null,
                onSaved: (val) => _customerName = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
                onSaved: (val) => _phone = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _partySize.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'จำนวนคน (ท่าน)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'กรุณากรอกจำนวนคน' : null,
                onSaved: (val) => _partySize = int.parse(val!),
              ),
              const SizedBox(height: 16),

              // เทคนิคใหม่ 1: เลือกวันที่ด้วย TableCalendar
              const Text('เลือกวันที่จอง:', style: TextStyle(fontWeight: FontWeight.bold)),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.week,
              ),
              const SizedBox(height: 16),

              // เทคนิคใหม่ 2: ให้คะแนนร้านด้วย RatingBar
              const Text('คะแนนความคาดหวัง/ความประทับใจ:', style: TextStyle(fontWeight: FontWeight.bold)),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  _rating = rating;
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  onPressed: _saveForm,
                  child: Text(isEdit ? 'อัปเดตการจอง' : 'บันทึกการจอง',
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);

      BookingModel booking = BookingModel(
        id: widget.booking?.id,
        customerName: _customerName,
        phone: _phone,
        restaurantName: _restaurantName,
        date: formattedDate,
        time: _time,
        partySize: _partySize,
        rating: _rating,
      );

      if (widget.booking == null) {
        await DatabaseHelper().addBooking(booking);
      } else {
        await DatabaseHelper().updateBooking(widget.booking!.id!, booking);
      }

      if (mounted) Navigator.pop(context);
    }
  }
}