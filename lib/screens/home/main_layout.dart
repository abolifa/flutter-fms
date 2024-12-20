import 'package:flutter/material.dart';
import 'package:fms_app/screens/home/home_screen.dart';
import 'package:fms_app/screens/home/tanks_screen.dart';
import 'package:fms_app/screens/home/transactions_screen.dart';
import 'package:fms_app/widgets/custom_app_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainLayout> {
  int _currentIndex = 0;

  // Define the pages
  final List<Widget> _pages = [
    HomeScreen(),
    TanksScreen(),
    TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current page
          });
        },
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.propane_tank),
            label: 'الخزانات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'المعاملات',
          ),
        ],
      ),
    );
  }
}
