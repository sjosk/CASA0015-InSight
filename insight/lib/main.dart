import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InSight',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
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
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildClickableArea(
                  context,
                  icon: Icon(Icons.route),
                  text: 'Indoor Guidance',
                  onTap: () {
                    
                  },
                ),
                _buildClickableArea(
                  context,
                  icon: Icon(Icons.elevator_rounded),
                  text: 'Floor Transition',
                  onTap: () {
                    
                  },
                ),
                _buildClickableArea(
                  context,
                  icon: Icon(Icons.directions_walk),
                  text: 'Emergency',
                  onTap: () {
                    
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableArea(BuildContext context, {required Icon icon, required String text, required VoidCallback onTap}) {
    Icon adjustedIcon = Icon(icon.icon, size: 40.0, color: icon.color);
    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 100.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
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
            ], //Children
          ),
        ),
      ),
    );
  }
}
class VoiceAssistant extends StatefulWidget {
  @override
  _VoiceAssistantState createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-UK");
    flutterTts.setSpeechRate(0.5);
  }

  Future speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        speak("Please follow the instructions on the screen.");
      },
      child: Text('Start Voice Assistant'),
    );
  }
}
Future vibratePhone() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate();
  }
}