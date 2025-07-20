import 'package:crony/firebase_options.dart';
import 'package:crony/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await _initializeFirebase(); // Wait for Firebase to initialize
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'CRONY',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

_initializeFirebase()async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}