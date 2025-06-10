import 'package:flutter/material.dart';
import 'package:TravelMate/screens/history_screen.dart';
import 'package:TravelMate/screens/landmarks_screen.dart';

class ScanHistoryWrapper extends StatefulWidget {
  const ScanHistoryWrapper({super.key});

  @override
  State<ScanHistoryWrapper> createState() => _ScanHistoryWrapperState();
}

class _ScanHistoryWrapperState extends State<ScanHistoryWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const LandmarksScreen(), const HistoryScreen()];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF6A85B1),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
