# 👁 InSight Mobile application  
## Indoor navigation app for the blind and visually impaired ​focusing on providing accurate floor recognition and transition guidance.   
GitHub 🔗 : https://github.com/sjosk/CASA0015-InSight/tree/main/insight   
Demo   🔗 : https://youtu.be/tKXNA3aKcyM  

![App Post](https://github.com/sjosk/CASA0015-InSight/blob/main/Mobile%20App%20Post.png)  
Landing page 🔗: https://sjosk.github.io/insight/index

# 👀 Introduction  
The inspiration for this indoor navigation application arose from a classroom session where videos were shown about how blind and visually impaired individuals use smartphones. This sparked a reflection on the limitations of GPS navigation within indoor environments, particularly due to the interference caused by buildings. Observations at the UCL One Pool Street building revealed that the accessibility features are in need of improvement; there is a notable absence of tactile paving and sufficient guidance systems.   
InSight aims to enhance the navigational experience for visually impaired individuals by leveraging the capabilities of beacons and smartphone features, such as voice feedback and vibration, to provide a more seamless and accessible learning environment.  

# ⭐️Features  
The app architecture diagram visually represents the structure of a Flutter mobile application designed for indoor navigation, floor transition, and emergency responses. The main entry point, the Home Page, offers users three primary functionalities: Indoor Navigation, Floor Transition, and Emergency.  

1. **Indoor Navigation Page**: This page integrates voice synthesis (TTS) to provide spoken directions, beacon detection to locate users within a building, and speech recognition to allow users to interact with the app via voice commands. It helps users navigate internally, with detailed pathways from one point to another.

2. **Floor Transition Page**: Utilizing beacon technology, this page aids users in navigating to crucial points like elevators or stairs in multi-floor buildings, enhancing the ease of moving through different building levels.

3. **Emergency Page**: Designed for urgent situations, it provides expedited routes to the main entrance and includes functionality to make emergency calls, ensuring quick evacuation or immediate contact with emergency services.

![Design](https://github.com/sjosk/CASA0015-InSight/blob/main/insight/assets/images/Design.png)  

# 🌻 Accessible Design for User Experience and Interface  

### 🎨 Color Universal Design
According to the Color Universal Design guidelines, the choice of colors was given special consideration. Considering that some groups have difficulty distinguishing colors, high-contrast options were selected, and commonly confused colours were avoided. Additionally, icons of distinct shapes were incorporated to provide users with an alternative recognition method.

### 📲 Feedback and Guidance  
The app incorporates external libraries such as Flutter Beacon for beacon interaction, Flutter TTS for text-to-speech functionality, Speech to Text for voice input, and Vibration for physical feedback, enhancing user experience and accessibility.  

# 📍 Get started with InSight  
## Guidance  
- Download the InSight from [here](https://github.com/sjosk/CASA0015-InSight/blob/main/insight/build0/app/outputs/flutter-apk/app-release.apk) (Android)
- Deploy and run InSight on any simulator or iOS/Andriod devices
- Before using the app, please remember to authorize the app to use your location, microphone, and phone functions.

## Plugin
- `flutter_tts: 3.2.2`     plugin for text-to-speech capabilities  
- `vibration: 1.7.3 `      plugin for Flutter that allows developers to control the vibration motor on devices  
- `speech_to_text: 6.6.1`  plugin for converting spoken words into text  
- `flutter_beacon: 0.5.1`  plugin for working with Bluetooth beacons. It is used for ranging and monitoring beacon devices  
- `url_launcher: 6.0.12`   plugin that enables you to launch URLs  
- `flutter_launcheer_icons: 0.9.2`  plugin for icons

## Biblography

1. Hoober, S. (2021) 'Color and Universal Design', Mobile Matters, 6 September.  Available at: <https://www.uxmatters.com/mt/archives/2021/09/color-and-universal-design.php> (Accessed: 28 March 2024).
2. Dart packages. (2022) flutter_beacon 0.5.1 | Dart Package.  Available at: <https://pub.dev/packages/flutter_beacon/versions> (Accessed 27 March 2024).  
3. Dart packages. (2024) speech_to_text: 6.6.1 | Dart Package.  Available at: <https://pub.dev/packages/speech_to_text> (Accessed 27 March 2024).
4. satyyyaamm (2024) 'Integrating iBeacons in Flutter: A Step-by-Step Guide', Medium, 7 January. Available at: <https://medium.com/@satyamt5152/integrating-ibeacons-in-flutter-a-step-by-step-guide-628b9bbe438f> (Accessed 29 March 2024).


# ✉️ Keep in touch  
SJ. Wu: cepwsj@gmail.com If you'd like to contribute to the app, don't hestite to get in contact with me.
