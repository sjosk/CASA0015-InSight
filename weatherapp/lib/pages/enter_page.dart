import 'package:flutter/material.dart';
import 'package:weatherapp/pages/subscribe_city.dart';


class EnterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width, 
            height: MediaQuery.of(context).size.height, 
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/enterBackground.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 60,
            top: 120,
            child: Container(
              height: 140, 
              width: 140, 
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/logo.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        Positioned(
            top: 295, 
            left: 50, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                Text('Morning Weather', style: TextStyle(fontSize: 28, color: const Color.fromRGBO(23, 23, 23, 1), fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Your best weather helper', style: TextStyle(fontSize: 18, color: Color.fromRGBO(23, 23, 23, 1))),
                Text('Alarm, Weather & Destination plan', style: TextStyle(fontSize: 18, color: Color.fromRGBO(23, 23, 23, 1))),
                SizedBox(height: 25),
                ElevatedButton(
                   child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16, 
                      color: const Color.fromRGBO(167, 73, 63, 1), 
                    ),
                  ),
                  onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SubscribeCitiesPage()),
                );
              },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(238, 195, 158, 1)), 
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 0, horizontal: 24)), // 内边距
                    
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

