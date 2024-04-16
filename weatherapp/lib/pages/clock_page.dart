import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/pages/alarm_pop.dart';

class ClockPage extends StatefulWidget {
  @override
  _AlarmClockPageState createState() => _AlarmClockPageState();
}

class _AlarmClockPageState extends State<ClockPage> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 8, minute: 0);  // 默认时间设置为上午8:00
  Timer? timer;
  bool _alarmFired = false;
  DateTime? _lastAlarmTime; // 添加字段存储上次闹钟时间

  @override
  void initState() {
    super.initState();
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
        (_lastAlarmTime == null || now.difference(_lastAlarmTime!).inMinutes >= 1)) {
      setState(() {
        _alarmFired = true;
        _lastAlarmTime = now;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AlarmPop())).then((_) {
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
    }
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
      // 如果没有保存的时间，使用默认时间
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
              child: Text("Set Morning Clock",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(35, 35, 35, 1)
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Alarm Time: ${_selectedTime.format(context)}',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _pickTime,
                      child: Text('Pick Time'),
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
