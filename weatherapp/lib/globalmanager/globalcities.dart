class GlobalCitiesManager {
  static final GlobalCitiesManager _instance = GlobalCitiesManager._internal();
  

  factory GlobalCitiesManager() {
    return _instance;
  }

  GlobalCitiesManager._internal();

  List<String> selectedCities = [];

  void addCity(String city) async {
    if (!selectedCities.contains(city)) {
      selectedCities.add(city);
    }
  }

  void removeCity(String city) {
    selectedCities.remove(city);
  }

 
}
