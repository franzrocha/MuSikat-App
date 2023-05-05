import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musikat_app/service_locators.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'music_player/music_player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mycompany.myapp.audio',
    androidNotificationChannelName: 'Audio Service Demo',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationIcon: 'mipmap/musikat_launcher',
  );

  setupLocators();

  runApp(const MyApp());
}
