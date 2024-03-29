import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/serices/weather_service.dart';

class AlarmPop extends StatefulWidget {
  const AlarmPop({super.key});

  @override
  State<AlarmPop> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AlarmPop> {
  //api key
  final _weatherService = WeatherService('7fbf36e5c795251df28123b325f63eef');
  Weather? _weather;

  //fetch weather
  _fetchWeather() async {
    //get the current city
    String cityName = await _weatherService.getCurrentCity();

    //get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }

    //any errors
    catch (e) {
      print(e);
    }
  }

  //weather animations

  //init state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //city name
            Text(_weather?.cityName ?? "loading city..."),

            //temperature
            Text('${_weather?.temperature.round()}℃')
          ],
        ),
      ),
    );
  }
}
