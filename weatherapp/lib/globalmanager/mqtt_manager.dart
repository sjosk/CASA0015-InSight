import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:weatherapp/models/config.dart'; 

class MQTTManager {
  late MqttServerClient client;

  MQTTManager() {
    client = MqttServerClient(Config.mqttServer, 'uniqueClientId');
    client.port = Config.mqttPort;
    client.keepAlivePeriod = 30;
    client.setProtocolV311();
  }

  Future<void> initializeMQTTClient() async {
    try {
      print('Trying to connect to the server...');
      await client.connect(Config.mqttUser, Config.mqttPassword);
    } catch (e) {
      print('Exception while trying to connect to the server: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
     
      client.subscribe('student/CASA0014/plant/ucjtdjw/moisture', MqttQos.atLeastOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        print('Received message: $payload from topic: ${c[0].topic}');
      });
    } else {
      print('ERROR: MQTT client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }
}
