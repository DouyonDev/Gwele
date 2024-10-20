import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Comptable/Comptable.dart';
import 'package:gwele/Screens/Lead/Leader.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/push_notification_service.dart';

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
        } else if (utilisateur.role == 'COMPTABLE') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Comptable()),
          );
        } else if (utilisateur.role == 'MEMBRE') {

          // Requête pour vérifier si l'utilisateur est un leader dans une équipe
          FirebaseFirestore.instance
              .collection('equipes') // Nom de la collection où sont stockées les équipes
              .where('leaderId', isEqualTo: utilisateur.id) // Vérifie si l'utilisateur est leader
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              // Si l'utilisateur est trouvé comme leader, navigation vers la page Leader
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Leader()),
              );
            } else {
              // Si l'utilisateur n'est pas un leader, navigation vers la page Participant
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Participant()),
              );
            }
          }).catchError((error) {
            print("Erreur lors de la vérification du rôle de leader : $error");
            // Gérer les erreurs si nécessaire
          });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Erreur",
                content: "Vous n'avez pas de rôle dans le système.",
              );
            },
          );
        }

        FirebaseMessaging messaging = FirebaseMessaging.instance;

        // Demander la permission (si nécessaire)
        await messaging.requestPermission();


        String vapidKey = "BMvfL_wZ9rnjGXPuzAHEWIBUTlaHB6xU4n_mGdGlTkhxY0wRlci6HMAhXP9sNYzk8e898FEQMWyNtfomf4nAzeM";

        // Obtenir le token

        try {
          String? token = await messaging.getToken(vapidKey: vapidKey);
          if (token != null) {
            print("Token FCM: $token");

            // Assurez-vous que le token n'est pas nul avant de l'utiliser
            if (token != null) {
              utilisateur.notificationToken = token;
              UtilisateurService().mettreAJourUtilisateur(utilisateur);
            } else {
              print("Erreur: Le token FCM est nul");
            }
          } else {
            print("Token non généré");
          }
        } catch (e) {
          print("Erreur lors de la génération du token : $e");
        }

        return utilisateur;
      } else {
        throw Exception("Utilisateur non trouvé dans Firestore");
      }
    } catch (e) {
      // Ferme l'indicateur de chargement si nécessaire (si utilisé dans l'appelant)
      Navigator.of(context).pop();
      // Affiche les erreurs à l'utilisateur via une modale
      String errorMessage;

      if (e is FirebaseAuthException) {
        // Gestion des erreurs Firebase Auth
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'L\'adresse e-mail est invalide.';
            break;
          case 'user-disabled':
            errorMessage = 'Le compte utilisateur a été désactivé.';
            break;
          case 'user-not-found':
            errorMessage = 'Aucun utilisateur trouvé pour cet e-mail.';
            break;
          case 'wrong-password':
            errorMessage = 'Mot de passe incorrect.';
            break;
          case 'invalid-credential':
            errorMessage = 'Les informations d\'identification fournies sont incorrectes, malformées ou ont expiré.'
                '\nVeuillez revoir votre adresse e-mail et mot de passe.';
            break;
          default:
            errorMessage = 'Erreur de connexion: ${e.message}';
            print(e);
        }
      } else {
        // Autres erreurs
        errorMessage = 'Erreur inconnue: $e';
      }

      // Affiche un message d'erreur à l'utilisateur
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return MessageModale(
            title: "Erreur",
            content: errorMessage,
          );
        },
      );

      print('Erreur de connexion: $e');
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

  //Fonction pour obtenir l'id de l'utilisateur connecté
  Future<String?> idUtilisateurConnecte() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // Retourne l'ID de l'utilisateur connecté
    }
    return null; // Si l'utilisateur n'est pas connecté
  }

  String? idUtilisateurConnect() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // Retourne l'ID de l'utilisateur connecté
    }
    return null; // Si l'utilisateur n'est pas connecté
  }

}
