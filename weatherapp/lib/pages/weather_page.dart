import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<WeatherPage> {
  //api key
  final _weatherService = WeatherService('7fbf36e5c795251df28123b325f63eef');
  Weather? _weather;

  //fetch weather
  _fetchWeather() async {
    //get the current city
    String cityName = await _weatherService.getCurrentCity();
    print('cityName:${cityName}');
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
      extendBodyBehindAppBar: true, 
      
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Backgroundrain.png'), 
            fit: BoxFit.cover, 
          ),
        ),
      ),
    );
  }
}
