import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'MainScreen.dart';
import 'pages/enter_page.dart'; 
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => EnterPage(),
        '/home': (context) => MainScreen(),  
       
      },
    );
  }
}
DateTime convertTimeToZone(DateTime time, String timeZoneName) {
  tz.Location location = tz.getLocation(timeZoneName);
  tz.TZDateTime tzDateTime = tz.TZDateTime.from(time, location);
  return tzDateTime;
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
}