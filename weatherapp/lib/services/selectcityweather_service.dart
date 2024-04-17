import 'package:http/http.dart' as http;
import 'dart:convert';

class CityWeatherService {
  final String apiKey;
  final String baseUrl = 'http://api.openweathermap.org/data/2.5/weather';

  CityWeatherService(this.apiKey);

  Future<String> fetchWeatherDescriptionForCity(String city) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$city&appid=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      String description = data['weather'][0]['main'];
      return description;
    } else {
      
      throw Exception('Failed to load weather for $city');
    }
  }

  Future<Map<String, String>> fetchWeatherForCities(List<String> cities) async {
    Map<String, String> cityWeatherDescriptions = {};

    for (String city in cities) {
      try {
        String description = await fetchWeatherDescriptionForCity(city);
        cityWeatherDescriptions[city] = description;
      } catch (e) {
        print(e); 
        cityWeatherDescriptions[city] = 'Unknown'; 
      }
    }

    return cityWeatherDescriptions;
  }
}
