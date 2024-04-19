import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmPop extends StatefulWidget {
  const AlarmPop({super.key});

  @override
  State<AlarmPop> createState() => _AlarmPopState();
}

class _AlarmPopState extends State<AlarmPop> {
  final _weatherService = WeatherService('7fbf36e5c795251df28123b325f63eef');
  Weather? _weather;
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/Clouds.json';

    switch (mainCondition.toLowerCase()) {
      case 'Clouds':
      case 'Mist':
      case 'Smoke':
      case 'Haze':
      case 'Dust':
      case 'Fog':
      case 'Rain':
        return 'assets/Rain.json';
      case 'Drizzle':
      case 'Shower rain':
        return 'assets/Rain.json';
      case 'Thunderstorm':
        return 'assets/Rain.json';
      case 'Clear':
        return 'assets/Clear.json';
      default:
        return 'assets/Clouds.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _playSound();
  }

  Future<void> _playSound() async {
    // Load and play the alarm sound
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm_sound.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/subscribeBack.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Wake up!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 60),
            Text(_weather?.cityName ?? "Loading city...",
                style: TextStyle(fontSize: 20)),
            if (_weather != null)
              SizedBox(
                width: 500.0,
                height: 200.0,
                child: Lottie.asset('assets/Clouds.json'),
              ),
            Text('${_weather?.temperature.round() ?? "..."}℃',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Stop Alarm'),
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(249, 234, 213, 1),
                onPrimary: const Color.fromRGBO(35, 35, 35, 1),
                minimumSize: Size(150, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
