import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/pages/alarm_pop.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ClockPage extends StatefulWidget {
  @override
  _AlarmClockPageState createState() => _AlarmClockPageState();
}

class _AlarmClockPageState extends State<ClockPage> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);
  Timer? timer;
  bool _alarmFired = false;
  bool _isAlarmEnabled = true;  // 新增闹钟启用状态
  DateTime? _lastAlarmTime;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _loadTime();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void checkTime() {
    final now = DateTime.now();
    if (TimeOfDay(hour: now.hour, minute: now.minute) == _selectedTime &&
        !_alarmFired &&
        _isAlarmEnabled &&  // Check if alarm is enabled
        (_lastAlarmTime == null ||
            now.difference(_lastAlarmTime!).inMinutes >= 1)) {
      setState(() {
        _alarmFired = true;
        _lastAlarmTime = now;
      });
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AlarmPop()))
          .then((_) {
        _resetAlarm();
      });
    }
  }

  void _resetAlarm() {
    setState(() {
      _alarmFired = false;
    });
  }

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null && time != _selectedTime) {
      setState(() {
        _selectedTime = time;
        _alarmFired = false;
      });
      _saveTime(time);
      if (_isAlarmEnabled) {
        scheduleAlarm(time);  // Only schedule if alarm is enabled
      }
    }
  }

  Future<void> scheduleAlarm(TimeOfDay time) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 10)); 
    var androidDetails = const AndroidNotificationDetails(
    'alarm_channel_id',  
    'Alarm',             
    importance: Importance.max,  
    priority: Priority.high,     
    fullScreenIntent: true,     
);

    var iosDetails = IOSNotificationDetails();
    var generalDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Time to Wake Up!',
      'Your alarm is ringing!',
      scheduledNotificationDateTime,
      generalDetails,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> _saveTime(TimeOfDay time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hour', time.hour);
    await prefs.setInt('minute', time.minute);
    print("Saved Time: ${time.hour}:${time.minute}");
  }

  Future<void> _loadTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? hour = prefs.getInt('hour');
    int? minute = prefs.getInt('minute');
    if (hour != null && minute != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
    } else {
     
      setState(() {
        _selectedTime = TimeOfDay(hour: 8, minute: 0);
      });
    }
    print("Loaded Time: ${_selectedTime.hour}:${_selectedTime.minute}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/subscribeBack.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 33.0, top: 88.0),
              child: Text(
                "Set Morning Clock",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(35, 35, 35, 1)),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    
                    Text(
                      'Alarm Time: ${_selectedTime.format(context)}',
                      style: TextStyle(fontSize: 24, color: Color.fromRGBO(35, 35, 35,1)),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _pickTime,
                      child: Text('Pick Time'),
                    ),
                    SizedBox(height:60),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isAlarmEnabled = !_isAlarmEnabled;  
                        });
                        if (_isAlarmEnabled) {
                          scheduleAlarm(_selectedTime);  
                        } else {
                          flutterLocalNotificationsPlugin.cancelAll();  
                        }
                      },
                      child: Text(_isAlarmEnabled ? 'Disable Alarm' : 'Enable Alarm'),
                      style: ElevatedButton.styleFrom(
                        primary: _isAlarmEnabled ? const Color.fromARGB(255, 255, 255, 255) : Color.fromRGBO(202, 202, 202, 1)  
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
