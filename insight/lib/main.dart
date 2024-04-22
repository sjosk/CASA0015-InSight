import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';
import 'dart:async'; 
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:collection/collection.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InSight',
      theme: ThemeData(
        primaryColor: Colors.yellow[700],
        primaryColorDark: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatelessWidget {
  Widget _buildClickableArea(BuildContext context, {required Icon icon, required String text, required VoidCallback onTap, required Color backgroundColor, }) {
    Icon adjustedIcon = Icon(icon.icon, size: 40.0, color: icon.color ?? Colors.white);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 100.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            adjustedIcon,
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color:  Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Icon(Icons.visibility),
            Image.asset('assets/images/icon.png', width: 40, height: 40),
            SizedBox(width: 8),
            Text('InSight'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildClickableArea(
            context,
            icon: Icon(Icons.route),
            text: 'Indoor Guidance',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IndoorNavigationPage())),backgroundColor: Color.fromARGB(244, 224, 169, 3),
          ),
          _buildClickableArea(
            context,
            icon: Icon(Icons.elevator_rounded),
            text: 'Floor Transition',
            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => FloorTransitionPage())),backgroundColor:  Color.fromARGB(244, 14, 106, 197),
          ),
          _buildClickableArea(
            context,
            icon: Icon(Icons.directions_walk),
            text: 'Emergency',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyPage())),backgroundColor:  Color.fromARGB(255, 228, 43, 43),
          ),
        ],
      ),
    );
  }
}



//Indoor Navigation Page
class IndoorNavigationPage extends StatefulWidget {
  @override
  _IndoorNavigationPageState createState() => _IndoorNavigationPageState();
}
class _IndoorNavigationPageState extends State<IndoorNavigationPage> {
  final FlutterTts flutterTts = FlutterTts();
  final List<Beacon> beacons = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentField = '';
  List<String> locations = ['Main entrance', 'CE LAB', 'Cafe', '1F Toilet', '2F Toilet']; 
  String? from;
  String? to;
  String currentFloor = "Loading..."; // Default value before beacon is detected
  String getNavigationInstructions(String from, String to) {
     Map<String, String> navigationInstructions = {
    'Main entrance-Cafe': 'Go through the door, Turn left, It is on your left-hand side',
    'Main entrance-1F Toilet': 'Go through the door, Turn Left and go straight, Tap your UCL card at your right hand side in front of the door, Toilet is on your right hand side when you enter the door',
    'Main entrance-CE LAB': 'Go through the door, Turn Left and go straight find the lift, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight till the end and push the door, CE LAB is on your right hand side',
    'Main entrance-2F Toilet': 'Go through the door, Turn Left and go straight find the lift, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left,Tap your UCL card on your right hand side, Go straight about 7 meter, Toilet entrance is on the right',
    'Cafe-Main entrance':'Turn right and go straight, It is on your right hand side',
    'Cafe-1F Toilet':'Turn Left and go straight, There is a door and please tap your UCL card on the right side, Go through the door and it is on your left side',
    'Cafe-CE LAB':'Go Straight 2 meter there are lifts on your left side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight until the end and push the door, CE LAB is on your right hand side',
    'Cafe-2F Toilet':'Go Straight 2 meter there are lifts on your left side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk till the end and turn left, Tap your UCL card on your right hand side, Go straight about 7 meter, Toilet entrance is on the right',
    '1F Toilet-Main entrance':'Turn right and push the button on your right side to open the door, Pass through the door and go straight 6 meter, Main Entrance is on your right hand side',
    '1F Toilet-Cafe':'Turn right and push the button on your right side to open the door, Pass through the door and go straight 2 meter, Main Entrance is on your right hand side',
    '1F Toilet-CE LAB':'Turn right and push the button on your right side to open the door, Pass through the door and turn left, Lifts are on your left hand side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight until the end and push the door, CE LAB is on your right hand side',
    '1F Toilet-2F Toilet':'Turn right and push the button on your right side to open the door, Pass through the door and turn left, Lifts are on your left hand side, Take the lift to Second Floor, Get out of the lift and turn left, After 3 meter turn right and go straight, Walk until the end and turn left, Tap your UCL card on your right hand side, Go straight about 7 meter, Toilet entrance is on the right',
    'CE LAB-Main entrance':'Pass through the door on your left, Go straight until the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Go straight 4 meter and turn right',
    'CE LAB-Cafe':'Pass through the door on your left, Go straight until the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side,Take the lift to first floor, Go straight 2 meter and turn right',
    'CE LAB-1F Toilet':'Pass through the door on your left, Go straight until the end and press the button on your right side, Out of the door turn right and go straight 8 meter,Lifts are on your left side,Take the lift to first floor, Turn right and go forward 1m and turn right again, There is a door and please tap your UCL card on the right side, Go through the door and it is on ypur left side',
    'CE LAB-2F Toilet':'Pass through the door on your left, Go straight 3 meter, Toilet entrance is on your left hand side',
    '2F Toilet-Main entrance':'Turn left when you pass through the toilet entrance door, Go straight till the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Go straight 4m and turn right',
    '2F Toilet-Cafe':'Turn left when you pass through the toilet entrance door, Go straight till the end and press the button on your right side, Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Go straight 2 meter and turn right',
    '2F Toilet-CE LAB':'Turn right when you pass through the toilet entrance door, Go straight until the end and pull the door, CE LAB is on your right hand side',
    '2F Toilet-1F Toilet':'Turn left when you pass through the toilet entrance door, Go straight till the end and press the button on your right side,Out of the door turn right and go straight 8 meter, Lifts are on your left side, Take the lift to first floor, Turn right and go forward 1m and turn right again, There is a door and please tap your UCL card on the right side, Go through the door and it is on ypur left side',
    'Main entrance-Mainentrance':'You are right here!',
    'Cafe-Cafe':'You are right here!',
    '1F Toilet-1F Toilet':'You are right here!',
    '2F Toilet-2F Toilet':'You are right here!',
    'CE LAB-CE LAB':'You are right here!',
  };

    String key = '$from-$to';
    return navigationInstructions[key] ?? 'No specific navigation instructions, available for this route.';
  }

  @override
  void initState() {
    super.initState();
    initBeaconScanning();
    flutterTts.setLanguage("en-UK");
    flutterTts.setSpeechRate(0.5);
  }



  void initBeaconScanning() async {
  try {
    await flutterBeacon.initializeScanning; 
    final regions = [Region(identifier: 'myBeacon', proximityUUID: 'FDA50693-A4E2-4FB1-AFCF-C6EB07647825')];
    flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty) {
        setState(() {
          beacons.clear();
          beacons.addAll(result.beacons);
          beacons.sort((a, b) => a.rssi.compareTo(b.rssi)); // Sorting by signal strength
          currentFloor = "Floor ${beacons.first.major}"; // Updating the floor number
          speak("Closest beacon at ${beacons.first.proximityUUID}, major: ${beacons.first.major}, minor: ${beacons.first.minor}");
        });
      } else {
        print('No beacons detected');
      }
    });
  } catch (e) {
    print('Error initializing beacon scanning: $e');
  }
}


  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  void _listen(String field) {
    _currentField = field; // Set current input field
    if (!_isListening) {
      _speech.initialize(onStatus: (val) => print('onStatus: $val'), onError: (val) => print('onError: $val')).then((available) {
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(onResult: (val) => setState(() {
            if (_currentField == 'from') {
              from = val.recognizedWords;
            } else if (_currentField == 'to') {
              to = val.recognizedWords;
            }
          }));
        }
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> vibratePhone() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indoor Navigation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Current Floor: $currentFloor', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            buildDropdownWithMic('From', from, 'from'),
            SizedBox(height: 20),
            buildDropdownWithMic('To', to, 'to'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: (){
                  if (from == null || to == null || from!.isEmpty || to!.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Incomplete Selection"),
                          content: Text("Please select both a 'From' and 'To' location."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Dismiss the alert dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    String temp = from ?? '';
                    from = to;
                    to = temp;
                    setState(() {});
                  }
                  },
                  style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor, 
                  onPrimary: Colors.white, 
                  ),
                  child: Icon(Icons.swap_horiz, size: 30),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (from != null && to != null && !from!.isEmpty && !to!.isEmpty) {
                      String instructions = getNavigationInstructions(from!, to!);
                      speak(instructions);
                      vibratePhone();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResultsPage(instructions: instructions)),
                      );
                    } else {
                      speak("Please select both a starting and ending location");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                  ),
                  child: Icon(Icons.search, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  

  Widget buildDropdownWithMic(String label, String? value, String field) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
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
                if (field == 'from') {
                  from = newValue;
                } else if (field == 'to') {
                  to = newValue;
                }
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(_isListening && _currentField == field ? Icons.mic : Icons.mic_none),
          onPressed: () => _listen(field),
        ),
      ],
    );
  }
}
  // Result Page
class ResultsPage extends StatelessWidget {
  final String instructions;

  ResultsPage({required this.instructions});

  @override
  Widget build(BuildContext context) {
    List<String> steps = instructions.split(', '); // Splits the instructions into steps based on commas.
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow InSight'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                steps[index],
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            );
          },
        ),
      ),
    );
  }
}

//Floor Transition Page
class FloorTransitionPage extends StatefulWidget {
  @override
  _FloorTransitionPageState createState() => _FloorTransitionPageState();
}

class _FloorTransitionPageState extends State<FloorTransitionPage> {
  String currentFloor = "Scanning...";
  double distanceToLift = 0.0;
  double distanceToStairs = 0.0;
  StreamSubscription<RangingResult>? beaconSubscription;

  @override
  void initState() {
    super.initState();
    initBeaconScanning();
  }

  void initBeaconScanning() async {
    try {
      await flutterBeacon.initializeScanning;
      final regions = [Region(identifier: 'myBeacon', proximityUUID: 'FDA50693-A4E2-4FB1-AFCF-C6EB07647825')];
      beaconSubscription = flutterBeacon.ranging(regions).listen((RangingResult result) {
        if (result.beacons.isNotEmpty) {
          result.beacons.sort((a, b) => a.rssi.compareTo(b.rssi)); 
          setState(() {
            currentFloor = "Floor ${result.beacons.first.major}";
            // Using firstWhereOrNull to safely handle no matches
            var liftBeacon = result.beacons.firstWhereOrNull((b) => b.major == 2 && b.minor == 100);
            var stairsBeacon = result.beacons.firstWhereOrNull((b) => b.major == 2 && b.minor == 4106);

            if (liftBeacon != null) {
              distanceToLift = calculateDistance(liftBeacon.rssi, -59);
            }
            if (stairsBeacon != null) {
              distanceToStairs = calculateDistance(stairsBeacon.rssi, -59);
            }
          });
        } else {
          print('No beacons detected');
        }
      });
    } catch (e) {
      print('Error initializing beacon scanning: $e');
    }
  }

  double calculateDistance(int rssi, int txPower) {
    return pow(10, ((txPower - rssi) / (10 * 2.0))) as double;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Floor Transition')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You are currently on \n$currentFloor Floor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Distance to lift: ${distanceToLift.toStringAsFixed(2)} meters', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Distance to stairs: ${distanceToStairs.toStringAsFixed(2)} meters', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    beaconSubscription?.cancel();
    super.dispose();
  }
}



//Emergency Page
class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final String emergencyNumber = "999";  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Leading you to the main entrance by taking stairs.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makePhoneCall,
              child: Text('Call Emergency', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall() async {
    Uri url = Uri.parse("tel:$emergencyNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
