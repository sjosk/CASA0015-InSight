import 'package:flutter/material.dart';
import 'package:weatherapp/services/weather_service.dart';
import 'package:weatherapp/services/cityname_service.dart';
import 'package:weatherapp/MainScreen.dart';
import 'package:weatherapp/globalmanager/globalcities.dart';

class SubscribeCitiesPage extends StatefulWidget {
  @override
  _SubscribeCitiesPageState createState() => _SubscribeCitiesPageState();
}


class _SubscribeCitiesPageState extends State<SubscribeCitiesPage> {
  TextEditingController _controller = TextEditingController();
  bool isKeyboardVisible = false;

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
    'Sydney',
    'Beijing',
  ];
 
  List<String> searchResults = [];
  bool isSearching = false;
  String currentCity = "Getting current location...";
  late WeatherService weatherService;
  late CityService cityService;

  @override
  void initState() {
    super.initState();
    weatherService = WeatherService('apiKey');
    cityService =
        CityService('9eda19280bmsh39cab15c5637f74p102d5cjsnc784311a0d1d');
    getCurrentCityName();
  }

  void getCurrentCityName() async {
    try {
      String cityName = await weatherService.getCurrentCity();
      if (cityName.isNotEmpty) {
        setState(() {
          currentCity = cityName;
          updateCityList(cityName, isCurrentCity: true);
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

  void updateCityList(String cityName, {bool isCurrentCity = false}) {
    if (!GlobalCitiesManager().selectedCities.contains(cityName)) {
      setState(() {
        GlobalCitiesManager().selectedCities.add(cityName);
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
  Widget buildCityTile(String city, {bool isCurrentCity = false}) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              city,
              style: TextStyle(color: const Color.fromRGBO(35, 35, 35, 1)),
            ),
          ),
          if (isCurrentCity)
            Text(
              'current city',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      ),
      onTap: () {
        setState(() {
          if (!GlobalCitiesManager().selectedCities.contains(city)) {
            GlobalCitiesManager().selectedCities.add(city);
          }
        });
      },
    );
  }

  Widget build(BuildContext context) {
   
    isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

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
              if (!isKeyboardVisible)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Selected",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(35, 35, 35, 1))),
                ),
              if (!isKeyboardVisible)
                Container(
                  height: 210,
                  padding: EdgeInsets.only(bottom: 20),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: GlobalCitiesManager().selectedCities
                        .map((city) => ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(city,
                                        style: TextStyle(
                                            color: const Color.fromRGBO(
                                                35, 35, 35, 1))),
                                  ),
                                  if (city == currentCity)
                                    Container(
                                      margin: EdgeInsets.only(left: 8),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('current city',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          )),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    color:
                                        const Color.fromRGBO(167, 73, 63, 1)),
                                onPressed: () {
                                  setState(() {
                                     GlobalCitiesManager().selectedCities.remove(city);
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero, 
                  itemCount: isSearching
                      ? searchResults
                          .where((city) => ! GlobalCitiesManager().selectedCities.contains(city))
                          .length
                      : famousCities
                          .where((city) => !GlobalCitiesManager().selectedCities.contains(city))
                          .length,
                  itemBuilder: (context, index) {
                    final city = isSearching
                        ? searchResults
                            .where((city) => !GlobalCitiesManager().selectedCities.contains(city))
                            .toList()[index]
                        : famousCities
                            .where((city) => !GlobalCitiesManager().selectedCities.contains(city))
                            .toList()[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          GlobalCitiesManager().selectedCities.add(city);
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Row(
                          children: [
                            Icon(Icons.add,
                                color: const Color.fromRGBO(167, 73, 63, 1)),
                            SizedBox(width: 10),
                            Text(city),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isKeyboardVisible)
                Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
