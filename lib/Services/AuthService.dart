import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/Utilisateur.dart';
import '../Screens/Admin/Admin.dart';
import '../Screens/Manager/Manager.dart';
import '../Screens/Participant/Participant.dart';
import '../Screens/Widgets/message_modale.dart';
import '../Screens/authentication_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour se connecter avec email et mot de passe
  Future<Utilisateur?> connexionAvecPassword(
      String email, String password, BuildContext context) async {
    try {
      // Connexion avec Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Signed in as ${userCredential.user?.email}');

      // Récupérer l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('utilisateurs') // Nom de la collection dans Firestore
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        // Créer une instance de Utilisateur avec les données récupérées
        Utilisateur utilisateur = Utilisateur.fromDocument(
            userDoc.data() as Map<String, dynamic>, userCredential.user!.uid);

        // Rediriger en fonction du rôle de l'utilisateur
        if (utilisateur.role == 'ADMIN') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Admin()), // Page pour admin
          );
        } else if (utilisateur.role == 'MANAGER') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Manager()),
          );
        } else if (utilisateur.role == 'MEMBRE') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Participant()),
          );
        } else {
          const MessageModale(
              title: "Erreur",
              content: "Vous n'avez pas de role dans le système");
        }

        return utilisateur;
      } else {
        throw Exception("Utilisateur non trouvé dans Firestore");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Gestion des erreurs Firebase Auth
        switch (e.code) {
          case 'invalid-email':
            print('L\'adresse e-mail est invalide.');
            break;
          case 'user-disabled':
            print('Le compte utilisateur a été désactivé.');
            break;
          case 'user-not-found':
            print('Aucun utilisateur trouvé pour cet e-mail.');
            break;
          case 'wrong-password':
            print('Mot de passe incorrect.');
            break;
          default:
            print('Erreur de connexion: ${e.message}');
        }
      } else {
        // Autres erreurs
        print('Erreur inconnue: $e');
      }
    }
    return null;
  }

  //Fonction de deconnexion
  Future<void> deconnexion(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Déconnexion de l'utilisateur
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<Map<String, dynamic>?> InformationUtilisateurConnecte() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData =
          await _firestore.collection('utilisateurs').doc(user.uid).get();
      return userData.data(); // Retourne les données utilisateur
    }
    return null; // Si l'utilisateur n'est pas connecté
  }

}
