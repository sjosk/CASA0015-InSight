import 'package:flutter/material.dart';

import 'pages/weather_page.dart';
import 'pages/clock_page.dart';
import 'pages/calendar_page.dart';
 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  final List<Widget> _widgetOptions = [
    ClockPage(),
    WeatherPage(
      forecastDetails: '',
    ),
    CalendarPage(),
  ];
  

  @override
  void initState() {
    super.initState();
    
  }

 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: BottomNavigationBar(
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.alarm, size: 30),
            ),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.cloud, size: 30),
              ),
              label: 'Weather'),
          BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.sort, size: 30),
              ),
              label: 'Subscription'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(247, 160, 90, 1),
        backgroundColor: Colors.transparent,
        unselectedItemColor: Color.fromARGB(255, 197, 197, 197),
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
