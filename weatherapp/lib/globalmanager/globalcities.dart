class GlobalCitiesManager {
  static final GlobalCitiesManager _instance = GlobalCitiesManager._internal();

  factory GlobalCitiesManager() {
    return _instance;
  }

  GlobalCitiesManager._internal();

  List<String> selectedCities = [];

  void addCity(String city) {
    if (!selectedCities.contains(city)) {
      selectedCities.add(city);
    }
  }

  void removeCity(String city) {
    if (selectedCities.length > 1) {
      selectedCities.remove(city);
    }
  }
}
