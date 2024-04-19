
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weatherapp/firebase_options.dart';
import 'package:weatherapp/models/firebase_api.dart';
import 'MainScreen.dart';
import 'pages/enter_page.dart'; 
import 'pages/alarm_pop.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  
);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await FirebaseApi().initNoticfications();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
        runApp(
          MaterialApp(
            home: AlarmPop(), 
          )
        );
      }
  );

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
