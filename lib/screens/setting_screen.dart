import 'package:crony/api/apis.dart';
import 'package:crony/helper/dialogs.dart';
import 'package:crony/screens/login_screen.dart';
import 'package:crony/widgets/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton.extended(
          backgroundColor: ColorScheme.of(context).inversePrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: ()async{
            Dialogs.showProgressbar(context);
            await APIs.updateActiveStatus(false);
            await APIs.auth.signOut().then((value)async{
              await GoogleSignIn().signOut().then((value){
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                APIs.auth = FirebaseAuth.instance;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              });
            });

          },icon: const Icon(Icons.logout),label: const Text('Logout'),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
        ],
      ),
    );
  }
}
