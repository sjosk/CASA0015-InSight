import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentField = ''; // 新增变量用于标记当前输入字段

  void swapFromAndTo() {
    setState(() {
      final temp = from;
      from = to;
      to = temp;
    });
  }

  void _listen(String field) async {
    _currentField = field; // 标记当前输入字段
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            if (_currentField == 'from') {
              from = val.recognizedWords;
            } else if (_currentField == 'to') {
              to = val.recognizedWords;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                ),
                IconButton(
                  icon: Icon(_isListening && _currentField == 'from' ? Icons.mic : Icons.mic_none),
                  onPressed: () => _listen('from'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                ),
                IconButton(
                  icon: Icon(_isListening && _currentField == 'to' ? Icons.mic : Icons.mic_none),
                  onPressed: () => _listen('to'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(
                  onPressed: swapFromAndTo,
                  child: Text('Exchange From and To'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // add searching logic
                    print('Searching from $from to $to');
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
