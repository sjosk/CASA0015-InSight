
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weatherapp/firebase_options.dart';
import 'package:weatherapp/models/firebase_api.dart';
import 'MainScreen.dart';
import 'pages/enter_page.dart'; 



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  
);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);

  await FirebaseApi().initNoticfications();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner:false,
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
