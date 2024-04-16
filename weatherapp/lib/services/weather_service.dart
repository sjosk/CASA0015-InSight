import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:weatherapp/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    print(
        'Sending request to $BASE_URL?q=$cityName&appid=$apiKey&units=metric');
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    // Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    print("Current permission status: $permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permission is permanently denied
        return "";
      }
    }
    if (permission == LocationPermission.denied) {
      // Permission denied temporarily
      return "";
    }

    print("Permission granted. Fetching location...");
    // Fetch current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    // Output the latitude and longitude
    print("Position: ${position.latitude}, ${position.longitude}");

    // Convert the location into a list of placemark objects
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      // Extract the city name from the first placemark
      String? city = placemarks[0].locality;
      print("City found: $city");
      return city ?? "";
    } catch (e) {
      print("Error fetching location placemark: $e");
      return "";
    }
  }

  Future<String> getForecastWeatherData(String cityName) async {
    var encodedCity = Uri.encodeComponent(cityName);
    String urlStr =
        "http://api.openweathermap.org/data/2.5/forecast?q=$encodedCity&units=metric&appid=$apiKey";
    var url = Uri.parse(urlStr);
    var response = await http.get(url);
    var result = StringBuffer();

    if (response.statusCode == 200) {
      var weatherJson = jsonDecode(response.body);
      var timezoneOffsetSeconds = weatherJson['city']['timezone'];
      var now =
          DateTime.now().toUtc().add(Duration(seconds: timezoneOffsetSeconds));
      print(now);
      var endOfPeriod = now.add(Duration(hours: 24));
      print(endOfPeriod);
      result.writeln("cities: ${weatherJson['city']['name']}");
      var lon = weatherJson['city']['coord']['lon'];
      var lat = weatherJson['city']['coord']['lat'];
      result.writeln("location: [$lon, $lat]");

      var dformatter = DateFormat('HH');

      for (var jsonData in weatherJson['list']) {
       
        var utcTimestamp =
            jsonData['dt'] * 1000; 
        var dateUtc =
            DateTime.fromMillisecondsSinceEpoch(utcTimestamp, isUtc: true);
        var localDate = dateUtc.add(Duration(
            seconds: timezoneOffsetSeconds)); 

        if (localDate.isAfter(now) && localDate.isBefore(endOfPeriod)) {
          result.writeln(
              "--- time:${dformatter.format(localDate)} ---");
          var weather = jsonData['weather'][0]['main'];
          result.writeln("weather:$weather");
          var temp = jsonData['main']['temp'];
          result.writeln("temp:${temp}°C");
        }
      }
    } else {
      print('fail:${response.statusCode}');
      return "fail:${response.statusCode}";
    }

    return result.toString();
  }
}
