import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  setupLocators();

  runApp(const MyApp());
}
