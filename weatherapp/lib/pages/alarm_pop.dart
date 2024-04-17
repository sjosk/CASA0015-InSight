import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';

class AlarmPop extends StatefulWidget {
  const AlarmPop({super.key});

  @override
  State<AlarmPop> createState() => _AlarmPopState();
}

class _AlarmPopState extends State<AlarmPop> {
  final _weatherService = WeatherService('7fbf36e5c795251df28123b325f63eef');
  Weather? _weather;

  _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alarm"),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Wake up!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(_weather?.cityName ?? "Loading city..."),
            if (_weather != null) Lottie.asset('assets/Rain.json'),
            Text('${_weather?.temperature.round() ?? "..."}℃'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                
              },
              child: Text('Stop Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
