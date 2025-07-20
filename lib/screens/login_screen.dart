import 'dart:developer';
import 'dart:io';
import 'package:crony/api/apis.dart';
import 'package:crony/helper/dialogs.dart';
import 'package:crony/main.dart';
import 'package:crony/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExist())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        Dialogs.showSnackbar(context, 'Login cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      if (mounted) {
        Dialogs.showSnackbar(context, 'Something went wrong: $e');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (APIs.auth.currentUser != null) {
      log('\nUser: ${APIs.auth.currentUser}');
      return HomeScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "WELCOME",
            style: GoogleFonts.bellota(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation/logo
              Lottie.asset('images/login.json'),
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Container(
                  height: 60,
                  width: 250,
                  decoration: BoxDecoration(),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                    ),
                    onPressed: () {
                      _handleGoogleBtnClick();
                    },
                    icon: Image.asset(
                      'images/google.png',
                      height: mq.height * .04,
                    ),
                    label: RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            children: [
                          TextSpan(text: 'Login With ',style: TextStyle(fontFamily: GoogleFonts.bellota().fontFamily)),
                          TextSpan(
                              text: 'Google',
                              style: TextStyle(fontFamily: GoogleFonts.yaldevi().fontFamily,fontWeight: FontWeight.w600))
                        ])),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// Sign out function
// _signOut()async{
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }
