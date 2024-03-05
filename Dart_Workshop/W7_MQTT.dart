import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(      
          appBar: AppBar(title: Text('MQTT Feeds')),
            body: MyListView()
        )
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  ListViewState createState()=> ListViewState();
}

class ListViewState extends State<MyListView>{
  late List<String> feeds; //string to widget

  @override
  void initState() {
    super.initState();
    feeds = [];
    startMQTT();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(feeds[index].toString()),
        );
      },
    );
  }

  updateList(String s){ 
  setState(() { 
    feeds.add(s); 
    });
}

Future<void> startMQTT() async{ 
  final client = MqttServerClient('mqtt.cetools.org', ''); 
  client.port=1884; //port number remember to change
  client.setProtocolV311(); 
  client.keepAlivePeriod= 30; 
  final String username = 'yourusername';
  final String password = 'yourpassword';; 
 
  try { await client.connect(username, password); 
  } catch (e) { print('client exception -$e'); 
  client.disconnect(); 
  } 
  
  if (client.connectionStatus!.state == MqttConnectionState.connected) { 
    print('Mosquittoclient connected'); 
    } else { 
      print('ERROR Mosquittoclient connection failed -disconnecting, state is ${client.connectionStatus!.state}'); 
      client.disconnect(); 
      } 
      
      const topic = 'topic_path'; 
      client.subscribe(topic, MqttQos.atMostOnce); 

      client.updates!.listen( (List<MqttReceivedMessage<MqttMessage?>>? c) { 
        final receivedMessage= c![0].payload as MqttPublishMessage; 
        final messageString= MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message); 
        print('Change notification:: topic is <${c[0].topic}>, payload is <--$messageString-->');
        updateList(messageString); 
        } ); 
        }



}


