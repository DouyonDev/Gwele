import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Services/AdminService.dart';
import 'Screens/dashbord/admin/dashbord.dart';
import 'firebase_options.dart';

import 'Colors.dart';
import 'Screens/bienvenue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LcQKFoqAAAAAGXW_hQyI399G93drX1fnqD0hY3p'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  await AdminService().checkAndCreateAdmin();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(), // Affiche un indicateur de chargement pendant l'initialisation
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Erreur lors de l\'initialisation de Firebase'), // Affiche un message d'erreur
              ),
            ),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Enlever le bandeau "DEBUG"
          theme: ThemeData(
            primaryColor: primaryColor, // Couleur principale
            hintColor: secondaryColor,  // Couleur d'accent
          ),
          home: Bienvenue(),  // Ecran de bienvenue
        );
      },
    );
  }
}