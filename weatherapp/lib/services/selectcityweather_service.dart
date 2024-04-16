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
      // 这里假设 "weather" 是一个包含天气状态的数组，并且我们只关注第一个状态
      String description = data['weather'][0]['main'];
      return description;
    } else {
      // 可以根据您的错误处理策略来抛出异常或返回默认描述
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
        print(e); // 打印错误信息或者做其他错误处理
        cityWeatherDescriptions[city] = 'Unknown'; // 未知或默认天气状态
      }
    }

    return cityWeatherDescriptions;
  }
}
