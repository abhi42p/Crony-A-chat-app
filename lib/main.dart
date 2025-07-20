import 'package:crony/firebase_options.dart';
import 'package:crony/screens/login_screen.dart';
import 'package:crony/widgets/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await _initializeFirebase(); // Wait for Firebase to initialize
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),);
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
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

_initializeFirebase()async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}