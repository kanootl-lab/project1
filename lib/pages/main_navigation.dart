import 'package:flutter/material.dart';
import 'home_booking_page.dart';
import 'special_deal_page.dart';
import 'member_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeBookingPage(),
    SpecialDealPage(),
    MemberPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'การจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'เมนูแนะนำ (API)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'ผู้จัดทำ',
          ),
        ],
      ),
    );
  }
}