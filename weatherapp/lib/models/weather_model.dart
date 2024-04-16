
class Weather{
  final String cityName;
  final double temperature;
  final String mainCondition;
  final double windSpeed;
  final double humidity;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.windSpeed,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json){
    return Weather(
      cityName: json['name'], 
      temperature: json['main']['temp'].toDouble(), 
      mainCondition: json['weather'][0]['main'],
      windSpeed: json['wind']['speed'].toDouble(), 
      humidity: json['main']['humidity'].toDouble(), 
    );
  }
}

class HourlyWeather {
  final String weather;
  final double temperature;
  final String time;

  HourlyWeather({required this.weather, required this.temperature, required this.time});
}