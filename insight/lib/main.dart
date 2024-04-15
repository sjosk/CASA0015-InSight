import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';

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
  Widget _buildClickableArea(BuildContext context, {required Icon icon, required String text, required VoidCallback onTap}) {
    Icon adjustedIcon = Icon(icon.icon, size: 40.0, color: icon.color ?? Colors.white);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 100.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
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
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
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
            Icon(Icons.visibility),
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IndoorNavigationPage())),
          ),
          _buildClickableArea(
            context,
            icon: Icon(Icons.elevator_rounded),
            text: 'Floor Transition',
            onTap: () {
              // Implement your floor transition logic or call to another page here
            },
          ),
          _buildClickableArea(
            context,
            icon: Icon(Icons.directions_walk),
            text: 'Emergency',
            onTap: () {
              // Implement your emergency handling or navigation logic here
            },
          ),
        ],
      ),
    );
  }
}

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
  List<String> locations = ['Main entrance', 'Room 107', 'Cafe', 'Library', 'Toilet']; 
  String? from;
  String? to;

  @override
  void initState() {
    super.initState();
    initBeaconScanning();
    flutterTts.setLanguage("en-UK");
    flutterTts.setSpeechRate(0.5);
  }

  void initBeaconScanning() async {
    await flutterBeacon.initializeScanning;
    final regions = [Region(identifier: 'myBeacon', proximityUUID: 'your-beacon-uuid')];
    flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty) {
        setState(() {
          beacons.clear();
          beacons.addAll(result.beacons);
          beacons.sort((a, b) => a.rssi.compareTo(b.rssi));
          speak("Closest beacon at ${beacons.first.proximityUUID}, major: ${beacons.first.major}, minor: ${beacons.first.minor}");
        });
      }
    });
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
            Text('Current Floor: ${from ?? "Not set"}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            buildDropdownWithMic('From', from, 'from'),
            SizedBox(height: 20),
            buildDropdownWithMic('To', to, 'to'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String temp = from ?? '';
                    from = to;
                    to = temp;
                    setState(() {});
                  },
                  child: Text('Exchange From and To'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (beacons.isNotEmpty && from != null && to != null) {
                      speak("Navigating from $from to $to using beacon with UUID: ${beacons.first.proximityUUID}");
                      vibratePhone();
                    } else {
                      speak("Please select both a starting and ending location, and ensure you are within range of beacons.");
                    }
                  },
                  child: Text('Start'),
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
