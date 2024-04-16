import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:weatherapp/globalmanager/globalcities.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key, required String forecastDetails});

  @override
  State<WeatherPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<WeatherPage> {
  String currentCity;
  List<HourlyWeather> hourlyForecast = [];

  _MyWidgetState()
      : currentCity = GlobalCitiesManager().selectedCities.isNotEmpty
            ? GlobalCitiesManager().selectedCities.first
            : 'No cities available';
  //api key
  final _weatherService = WeatherService('7fbf36e5c795251df28123b325f63eef');

  Weather? _weather;

  //fetch weather
  _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather(currentCity);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Failed to fetch current weather: $e');
    }
  }

  //init state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchForecastData();
    //fetch weather on startup
    _fetchWeather();
  }

  Future<void> _fetchForecastData() async {
    String forecastData =
        await _weatherService.getForecastWeatherData(currentCity);
    _parseForecastData(forecastData);
    print(forecastData);
  }

 void _parseForecastData(String data) {
  RegExp regExp = RegExp(
      r'--- time:(.*?) ---\s*weather:(.*?)\stemp:(.*?)°C\s*',
      dotAll: true);
  Iterable<Match> matches = regExp.allMatches(data);

  List<HourlyWeather> parsedData = [];
  for (var match in matches) {
    parsedData.add(HourlyWeather(
      weather: match.group(2)!.trim(), // Group 2 is the weather
      temperature: double.parse(match.group(3)!), // Group 3 is the temperature
      time: match.group(1)!.trim(), // Group 1 is the time
    ));
  }

  if (parsedData.isEmpty) {
    print('No data parsed. Check the regular expression.');
  } else {
    setState(() {
      hourlyForecast = parsedData;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    int maxTempIndex = 0;
    int minTempIndex = 0;
    double maxTemp = double.negativeInfinity;
    double minTemp = double.infinity;

    for (int i = 0; i < hourlyForecast.length; i++) {
      double temp = hourlyForecast[i].temperature;
      if (temp > maxTemp) {
        maxTemp = temp;
        maxTempIndex = i;
      }
      if (temp < minTemp) {
        minTemp = temp;
        minTempIndex = i;
      }
    }
    List<FlSpot> spots = hourlyForecast
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.temperature))
        .toList();
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
                                  _fetchWeather();
                                  _fetchForecastData();
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
                padding: EdgeInsets.only(top: 40, bottom: 0),
                child: Text(
                  currentCity,
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 0, bottom: 0),
                child: Text('${_weather?.temperature.round()}°',
                    style: TextStyle(fontSize: 72, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 0),
                child: Text('${_weather?.mainCondition}',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.air, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text('Wind Speed: ${_weather?.windSpeed.round()}    |    ',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                    Icon(Icons.water_drop, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text('Humidity: ${_weather?.humidity.round()}',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 0, left: 40, right: 40),
                height: 150,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  removeLeft: true,
                  removeRight: true,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: hourlyForecast.length,
                    itemBuilder: (context, index) {
                      var forecast = hourlyForecast[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 0 : 20,
                          right: index == hourlyForecast.length - 1 ? 40 : 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(forecast.time,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            Text(forecast.weather,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            Text('${forecast.temperature.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 0, left: 50, right: 50),
                  height: 60,
                  color: Colors.transparent,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              return LineTooltipItem(
                                '${flSpot.y.toStringAsFixed(2)}°C at ${hourlyForecast[flSpot.x.toInt()].time}:00',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                        touchCallback: (LineTouchResponse touchResponse) {},
                        handleBuiltInTouches: true,
                      ),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 0, 
                          getTitles: (value) {
                            if (value.toInt() == maxTempIndex) {
                              return 'max'; 
                            }
                            
                            return ''; 
                          },
                          getTextStyles: (context, value) => const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 0, 
                          getTitles: (value) {
                           
                            if (value.toInt() == minTempIndex) {
                              return 'min'; 
                            }
                            return ''; 
                          },
                          getTextStyles: (context, value) => const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        leftTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: hourlyForecast.length.toDouble() - 1,
                      minY:
                          hourlyForecast.map((e) => e.temperature).reduce(min),
                      maxY:
                          hourlyForecast.map((e) => e.temperature).reduce(max),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          colors: [Colors.blue],
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                if (index == maxTempIndex ||
                                    index == minTempIndex) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.red,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                } else {
                                  return FlDotCirclePainter(
                                    radius: 0,
                                  );
                                }
                              }),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
