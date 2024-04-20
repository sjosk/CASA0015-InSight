/*
    Get date and time - uses the ezTime library at https://github.com/ropg/ezTime -
    and then show data from a DHT22 on a web page served by the Huzzah and
    push data to an MQTT server - uses library from https://pubsubclient.knolleary.net

    Duncan Wilson
    CASA0014 - 2 - Plant Monitor Workshop
    May 2020
*/

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <PubSubClient.h>


// Wifi and MQTT
#include "arduino_secret.h" 
/*
**** please enter your sensitive data in the Secret tab/arduino_secrets.h
**** using format below

#define SECRET_SSID "ssid name"
#define SECRET_PASS "ssid password"
#define SECRET_MQTTUSER "user name - eg student"
#define SECRET_MQTTPASS "password";
 */

const char* ssid     = SECRET_SSID;
const char* password = SECRET_PASS;
const char* mqttuser = SECRET_MQTTUSER;
const char* mqttpass = SECRET_MQTTPASS;

ESP8266WebServer server(80);
const char* mqtt_server = "mqtt.cetools.org";
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;
const int pirPin = 2;  
int send = 2;
int pirState = LOW; 



void setup() {


  // open serial connection for debug info
  Serial.begin(115200);
  delay(100);

  // start DHT sensor
  pinMode(pirPin, INPUT); 
 

  // run initialisation functions
  startWifi();

  client.setServer(mqtt_server, 1884);
  client.setCallback(callback);

}

void loop() {
  // handler for receiving requests to webserver
  value = digitalRead(pirPin);  

  if (value == HIGH) { 
    if (pirState == LOW) {
      send = 1;
      Serial.println("Motion detected!");
      pirState = HIGH;
    }
  } else {
    if (pirState == HIGH) {
      send = 2;
      Serial.println("Motion ended!");
      pirState = LOW;
    }
  }
  delay(2000); 

  sendMQTT();
 
  client.loop();
}


void startWifi() {
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  // check to see if connected and wait until you are
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}



void sendMQTT() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();


  snprintf (msg, 50, "%.0i", send);
  Serial.print("Publish message for m: ");
  Serial.println(msg);
  client.publish("student/CASA0014/plant/ucjtdjw/detect", msg);

}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  // Switch on the LED if an 1 was received as first character
  if ((char)payload[0] == '1') {
    digitalWrite(BUILTIN_LED, LOW);   // Turn the LED on (Note that LOW is the voltage level
    // but actually the LED is on; this is because it is active low on the ESP-01)
  } else {
    digitalWrite(BUILTIN_LED, HIGH);  // Turn the LED off by making the voltage HIGH
  }

}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    
    // Attempt to connect with clientID, username and password
    if (client.connect(clientId.c_str(), mqttuser, mqttpass)) {
      Serial.println("connected");
      // ... and resubscribe
      client.subscribe("student/CASA0014/plant/ucjtdjw/inTopic");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

