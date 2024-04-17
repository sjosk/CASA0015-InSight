import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'MainScreen.dart';
import 'pages/enter_page.dart'; 
import 'pages/alarm_pop.dart'; // 确保你有一个导入AlarmPop的路径

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地通知插件
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  // 初始化并设置选择通知时的动作
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
        runApp(
          MaterialApp(
            home: AlarmPop(), // 当用户点击通知时，直接打开AlarmPop页面
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
