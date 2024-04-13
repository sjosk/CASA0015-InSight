import 'dart:convert';
import 'package:http/http.dart' as http;

class CityService {
  
  final String apiKey;
  final String baseUrl = 'http://geodb-free-service.wirefreethought.com/v1/geo/cities';

  Future<List<String>> searchCities(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse('$baseUrl?namePrefix=$query&limit=10&offset=0&hateoasMode=false&apiKey=$apiKey');
    print('Sending request to: $url');  

    final response = await http.get(url);
    print('Response status: ${response.statusCode}');  
    print('Response body: ${response.body}');  

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cities = data['data'] as List;
      List<String> cityNames = cities.map((city) => city['city'] as String).toList();
      print('Parsed city names: $cityNames');  
      return cityNames;
    } else {
      throw Exception('Failed to load city data');
    }
  }
   CityService(this.apiKey); 
}