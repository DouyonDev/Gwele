/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Screens/authentication_screen.dart';
import 'package:gwele/Services/AuthService.dart';

class AuthCheck extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Affiche un écran de chargement
        } else if (snapshot.hasData) {
          User? user = snapshot.data; // Assurez-vous que `data` est de type `User?`

          if (user != null) {
            try {
              UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                email: user.email,
                password: user.password, // Assurez-vous que `user.password` n'est pas nul
              );

              // Utilisez userCredential ici (par exemple, pour naviguer ou afficher un message de succès)
            } catch (e) {
              print("Erreur de connexion: $e");
              // Gérer l'erreur de connexion (afficher un message d'erreur, etc.)
            }
          } else {
            print("L'utilisateur est nul");
            // Gérer le cas où l'utilisateur est nul (afficher un message ou rediriger)
          }

          User? user = FirebaseAuth.instance.currentUser;
          // L'utilisateur est connecté, on appelle la redirection
          return FutureBuilder(
            future: AuthService().RedirectionUtilisateur(
                user, context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: backgroundColor,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
                      crossAxisAlignment: CrossAxisAlignment.center, // Centre horizontalement
                      children: [
                        Image.asset(
                          'assets/images/logoGwele.png',
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                );

              } else if (snapshot.hasError) {
                return const Text("Erreur lors de la redirection.");
              } else {
                return Container(); // Placeholder, car la redirection est déjà faite
              }
            },
          );
        } else {
          // L'utilisateur n'est pas connecté
          return LoginScreen();
        }
      },
    );
  }
}
*/