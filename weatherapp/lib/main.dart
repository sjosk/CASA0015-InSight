import 'package:flutter/material.dart';
import 'MainScreen.dart';
import 'pages/enter_page.dart'; 

void main() {
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