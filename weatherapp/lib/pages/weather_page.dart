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
    // Gets the width and height of the screen
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Backgroundrain.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 80),
                height: 270,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('New York'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('London'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('London',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('15°',
                    style: TextStyle(fontSize: 40, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('Cloudy',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('Additional info',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Option 1',
                          style: TextStyle(color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Option 2',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                    child: Text('Line Chart Placeholder',
                        style: TextStyle(color: Colors.black))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
