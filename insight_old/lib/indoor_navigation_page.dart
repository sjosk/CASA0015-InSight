import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IndoorNavigationPage(),
    );
  }
}

class IndoorNavigationPage extends StatefulWidget {
  @override
  _IndoorNavigationPageState createState() => _IndoorNavigationPageState();
}

class _IndoorNavigationPageState extends State<IndoorNavigationPage> {
  String currentFloor = "1F";
  String? from;
  String? to;
  List<String> locations = ['Main entrance', 'Room 107', 'Cafe', 'Library', 'Toilet']; 

  void swapFromAndTo() {
    setState(() {
      final temp = from;
      from = to;
      to = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Row(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: <Widget>[
            Icon(Icons.route), 
            SizedBox(width: 8), 
            Text('Indoor Guidance'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Current Floor: $currentFloor', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: from,
              decoration: InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(),
              ),
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  from = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: to,
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
              ),
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  to = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: swapFromAndTo,
                  child: Text('Exchange From and To'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // add searching
                    print('Searching $from to $to ');
                  },
                  child: Text('Search'),
                ),
              ],
            ),
            // Result Widget
          ],
        ),
      ),
    );
  }
}
