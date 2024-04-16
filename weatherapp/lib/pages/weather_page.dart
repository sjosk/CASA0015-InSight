import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:weatherapp/globalmanager/globalcities.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _MyWidgetState();
}


class _MyWidgetState extends State<WeatherPage> {
  String currentCity;

  _MyWidgetState() : currentCity = GlobalCitiesManager().selectedCities.isNotEmpty ? GlobalCitiesManager().selectedCities.first : 'No cities available';
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
                padding: EdgeInsets.only(top: 70, bottom: 60),
                height: 270,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: GlobalCitiesManager()
                      .selectedCities
                      .map((city) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  currentCity = city;
                                });
                              },
                              child: Text(city),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.all(8),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 0),
                child: Text(
                  currentCity, 
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left:10, top: 0, bottom: 0),
                child:Text(
                  '${_weather?.temperature.round()}°',
                  style: TextStyle(fontSize: 72, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text('${_weather?.mainCondition}',
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
