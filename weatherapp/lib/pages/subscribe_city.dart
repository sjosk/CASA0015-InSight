import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:weatherapp/services/cityname_service.dart';
import 'package:weatherapp/MainScreen.dart';

class SubscribeCitiesPage extends StatefulWidget {
  @override
  _SubscribeCitiesPageState createState() => _SubscribeCitiesPageState();
}

class _SubscribeCitiesPageState extends State<SubscribeCitiesPage> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> famousCities = [
    "New York",
    "London",
    "Tokyo",
    "Paris",
    "Berlin"
  ];
  List<String> selectedCities = [];
  List<String> searchResults = [];
  bool isSearching = false;
  String currentCity = "Getting current location...";
  late WeatherService weatherService;
  late CityService cityService;

  @override
  void initState() {
    super.initState();
    getCurrentCityName();
    cityService =
        CityService('9eda19280bmsh39cab15c5637f74p102d5cjsnc784311a0d1d');
  }

  void getCurrentCityName() async {
    try {
      String cityName = await weatherService.getCurrentCity();
      if (cityName.isNotEmpty) {
        setState(() {
          currentCity = cityName;
          selectedCities.add(cityName); // Adds to the list of selected cities
        });
      } else {
        setState(() {
          currentCity = "Failed to get location";
        });
      }
    } catch (e) {
      setState(() {
        currentCity = "Error getting city: $e";
      });
    }
  }

  void startSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    try {
      final results = await cityService.searchCities(query);
      setState(() {
        isSearching = true;
        searchResults = results;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      print('Error searching cities: $e');
    }
  }

  // Helper method to build city tiles
  Widget buildCityTile(String city) {
    return ListTile(
      title: Text(
        city,
        style: TextStyle(color: const Color.fromRGBO(35, 35, 35, 1)),
      ),
      onTap: () {
        setState(() {
          if (!selectedCities.contains(city)) {
            selectedCities.add(city);
          }
        });
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/subscribeBack.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Subscribe Cities",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(35, 35, 35, 1))),
              ),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: const Color.fromRGBO(35, 35, 35, 1)),
                      suffixIcon: isSearching
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                // Clear the search box and update the status
                                _controller.clear();
                                setState(() {
                                  isSearching = false;
                                  searchResults = [];
                                });
                              },
                            )
                          : null,
                      fillColor: const Color.fromRGBO(241, 208, 177, 1),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Search city name...",
                    ),
                    onChanged: startSearch,
                    controller:
                        _controller, // Add the TextEditingController Controller
                  )),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Selected",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(35, 35, 35, 1))),
              ),
              ...selectedCities
                  .map((city) => ListTile(
                        title: Text(city,
                            style: TextStyle(
                                color: const Color.fromRGBO(35, 35, 35, 1))),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,
                              color: const Color.fromRGBO(167, 73, 63, 1)),
                          onPressed: () {
                            setState(() {
                              selectedCities.remove(city);
                            });
                          },
                        ),
                      ))
                  .toList(),
              Expanded(
                child: ListView.builder(
                  itemCount: isSearching
                      ? (searchResults.isNotEmpty ? searchResults.length : 1)
                      : famousCities.length,
                  itemBuilder: (context, index) {
                    final city = isSearching
                        ? searchResults[index]
                        : famousCities[index]; 
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (!selectedCities.contains(city)) {
                            selectedCities.add(city); 
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15), 
                        child: Row(
                          children: [
                            Icon(Icons.add,
                                color: const Color.fromRGBO(
                                    167, 73, 63, 1)), 
                            SizedBox(width: 10), 
                            Text(city), 
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainScreen()),
                      );
                    },
                    child: Text("Enter"),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(250, 235, 216, 1),
                      onPrimary: const Color.fromRGBO(35, 35, 35, 1),
                      padding: EdgeInsets.symmetric(
                          horizontal: 35.0, vertical: 12.0),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
