import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weatherapp/models/weather_model.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:weatherapp/globalmanager/globalcities.dart';

import 'package:weatherapp/globalmanager/mqtt_manager.dart';
import 'package:mqtt_client/mqtt_client.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key, required String forecastDetails});

  @override
  State<WeatherPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<WeatherPage> {
  final GlobalCitiesManager manager = GlobalCitiesManager();
  List<String> cityWeathers = [];
  late MQTTManager _mqttManager;
  String latestMessage = "";
  String currentCity;
  late String MQTT;
  bool hasAlertBeenShown = false;
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
    _setupMQTT();
    refreshWeathers();
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: 'basic_channel',
              channelName: 'Weather Notifications',
              channelDescription: 'Notification channel for weather alerts',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        debug: true);
  }

  void createWeatherNotification(String title, String body) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: title,
      body: body,
    ));
  }

  void _setupMQTT() {
    _mqttManager = MQTTManager();
    _mqttManager.initializeMQTTClient();

    _mqttManager.client.onConnected = () {
      _mqttManager.client.subscribe(
          "student/CASA0014/plant/ucjtdjw/moisture", MqttQos.atLeastOnce);
    };

    _mqttManager.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) {
      if (c.isNotEmpty) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        if (c[0].topic == "student/CASA0014/plant/ucjtdjw/moisture") {
          latestMessage = payload;
          print('Received detect condition: $latestMessage');
        }
        if (latestMessage == "1" &&
            !hasAlertBeenShown &&
            containsRainOrSnow()) {
          _showRainOrSnowAlert();
          hasAlertBeenShown = true;
        }
      }
    });
  }

  Future<void> _fetchForecastData() async {
    String forecastData =
        await _weatherService.getForecastWeatherData(currentCity);
    _parseForecastData(forecastData);
  }

  Future<void> refreshWeathers() async {
    List<String> tempWeathers = [];
    for (String city in manager.selectedCities) {
      final weather = await _weatherService.getWeather(city);
      String weatherCondition = weather.mainCondition;
      tempWeathers.add(weatherCondition);
    }
    setState(() {
      cityWeathers = tempWeathers;
    });
    print("Current cities: ${manager.selectedCities.join(', ')}");
    print("Current weathers: $cityWeathers");
  }

  void _parseForecastData(String data) {
    RegExp regExp = RegExp(
        r'--- time:(.*?) ---\s*weather:(.*?)\stemp:(.*?)°C\s*',
        dotAll: true);
    Iterable<Match> matches = regExp.allMatches(data);

    List<HourlyWeather> parsedData = [];
    for (var match in matches) {
      parsedData.add(HourlyWeather(
        weather: match.group(2)!.trim(),
        temperature: double.parse(match.group(3)!),
        time: match.group(1)!.trim(),
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

  String getIconPath(String weatherDescription) {
    switch (weatherDescription) {
      case 'Clear':
        return 'assets/icons/clear.png';
      case 'Clouds':
        return 'assets/icons/clouds.png';
      case 'Rain':
        return 'assets/icons/rain.png';
      case 'Snow':
        return 'assets/icons/snow.png';
      default:
        return 'assets/icons/clouds.png';
    }
  }

  String getIconPathselect(String weatherDescription) {
    switch (weatherDescription) {
      case 'Clear':
        return 'assets/icons/clearselected.png';
      case 'Clouds':
        return 'assets/icons/cloudsselect.png';
      case 'Rain':
        return 'assets/icons/rainselect.png';
      case 'Snow':
        return 'assets/icons/snowselect.png';
      default:
        return 'assets/icons/cloudsselect.png';
    }
  }

  bool containsRainOrSnow() {
    return cityWeathers.any((weather) =>
        weather.contains("Rain") ||
        weather.contains("Snow") ||
        weather.contains("Drizzle") ||
        weather.contains("Thunderstorm ") ||
        weather.contains("Mist") ||
        weather.contains("Smoke") ||
        weather.contains("Haze"));
  }

  void _showRainOrSnowAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reminder"),
          content: Text(
              "Weather forecast for rain or snow, please remember to bring an umbrella!"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    createWeatherNotification("Weather Alert",
        "Weather forecast for rain or snow, please remember to bring an umbrella!");
  }

  @override
  Widget build(BuildContext context) {
    int maxTempIndex = 0;
    int minTempIndex = 0;
    double maxTemp = double.negativeInfinity;
    double minTemp = double.infinity;
    bool isRainOrSnow = containsRainOrSnow();

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
            image: AssetImage(isRainOrSnow
                ? 'assets/images/Backgroundrain.png'
                : 'assets/images/Backgroundlight.png'),
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
                      .asMap()
                      .entries
                      .map((entry) {
                    String city = entry.value;
                    int index = entry.key;
                    String weatherDescription = cityWeathers.length > index
                        ? cityWeathers[index]
                        : "Unknown";

                    String iconPath = currentCity == city
                        ? getIconPathselect(weatherDescription)
                        : getIconPath(weatherDescription);

                    Random random = Random();

                    double alignValue = random.nextDouble();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            currentCity = city;
                            _fetchWeather();
                            _fetchForecastData();
                          });
                        },
                        child: Align(
                          alignment: Alignment(0, alignValue * 2 - 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(iconPath, width: 70, height: 70),
                              Text(
                                city,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromRGBO(1, 44, 65, 1)),
                              ),
                            ],
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) =>
                                      Colors.transparent),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) =>
                                      Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 16)),
                        ),
                      ),
                    );
                  }).toList(),
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
                padding:
                    EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 0),
                alignment: Alignment.centerLeft,
                child: Text(
                  '24 hours weather forecast',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 40, right: 40),
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
                      String iconPath = getIconPath(forecast.weather);
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
                                    color: Colors.white, fontSize: 12)),
                            Image.asset(iconPath, width: 40, height: 40),
                            Text(forecast.weather,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            Text('${forecast.temperature.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
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
                        touchCallback: (FlTouchEvent event,
                            LineTouchResponse? touchResponse) {},
                        handleBuiltInTouches: true,
                      ),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 0,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              const style = TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );

                              if (value.toInt() == maxTempIndex) {
                                return Padding(
                                  padding:
                                      EdgeInsets.all(6), 
                                  child: Text('max', style: style),
                                );
                              }

                              return Padding(
                                padding:
                                    EdgeInsets.all(6), 
                                child: Text('', style: style),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22, 
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final textStyle = TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              );

                              String text;
                              if (value.toInt() == minTempIndex) {
                                text = 'min'; 
                              } else {
                                text = '';
                              }

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4), 
                                child: Text(text, style: textStyle),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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
                          color: const Color.fromRGBO(249, 234, 213, 1),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                if (index == maxTempIndex ||
                                    index == minTempIndex) {
                                  return FlDotCirclePainter(
                                    radius: 5,
                                    color: Color.fromRGBO(156, 75, 73, 1),
                                    strokeWidth: 0,
                                    strokeColor:
                                        Color.fromRGBO(249, 234, 213, 1),
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
