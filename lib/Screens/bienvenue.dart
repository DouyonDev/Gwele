import 'package:flutter/material.dart';
import 'dart:async';

import '../Colors.dart';
import 'authentication_screen.dart';

class Bienvenue extends StatefulWidget {
  @override
  BienvenueState createState() => BienvenueState();
}

class BienvenueState extends State<Bienvenue> {
  @override
  void initState() {
    super.initState();

    // Naviguer vers la page de connexion après 5 secondes
    Timer(const Duration(seconds: 0), () {
      // Vérifier si le widget est encore monté avant de naviguer
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Couleur de fond
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/images/logoGwele.png", // Chemin vers le logo
                height: 200,
              ),
              const SizedBox(height: 100),
              const Text(
                "Bienvenue",
                style: TextStyle(
                  fontSize: 24,
                  color: primaryColor, // Couleur primaire
                ),
              ),
              const SizedBox(height: 100),
              const Text(
                "Simplifiez la gestion de vos réunions, "
                    "tâches et projets en toute efficacité. "
                    "Profitez d'une interface intuitive pour "
                    "vous aider à rester organisé et productif.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: secondaryColor, // Couleur secondaire
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
