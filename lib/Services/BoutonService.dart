import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/Equipe.dart';
import '../Models/Reunion.dart';
import '../Models/Tache.dart';
import '../Models/Utilisateur.dart';
import '../Screens/Widgets/message_modale.dart';
import '../Screens/authentication_screen.dart';
import 'AuthService.dart';
import 'EquipeService.dart';
import 'FichiersService.dart';
import 'ReunionService.dart';
import 'UtilisateurService.dart';

class BoutonService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final AuthService authService = AuthService();
  final ReunionService reunionService = ReunionService();
  final FichiersService fichiersService = FichiersService();

  // Bouton pour la connexion
  Future<void> boutonConnexion(GlobalKey<FormState> formKey, String email,
      String password, BuildContext context) async {
    final isValid = formKey.currentState?.validate();
    if (isValid != null && isValid) {
      formKey.currentState?.save();
      try {
        Utilisateur? utilisateur =
            await authService.connexionAvecPassword(email, password, context);

        if (utilisateur != null) {
          // Afficher un message de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Succès",
                content: "Connexion réussie",
              );
            },
          );
        }
      } catch (e) {
        // Gérer les erreurs et afficher une modale d'erreur
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const MessageModale(
              title: "Erreur",
              content: "Problème lors de la connexion.",
            );
          },
        );
        print("le probleme est : ");
        print(e);
      }
    }
  }

  //Bouton pour enregistrer un manager
  Future<void> BtnAjouterManager(GlobalKey<FormState> formKey,
      BuildContext context, String prenom, String nom, String email) async {
    final isValid = formKey.currentState?.validate();
    if (isValid != null && isValid) {
      formKey.currentState?.save();
      try {
        // Récupérer l'ID du formateur connecté
        final adminId = FirebaseAuth.instance.currentUser?.uid;

        // Création de l'utilisateur apprenant dans Firebase Authentication avec un mot de passe par défaut
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: '12345678', // Mot de passe par défaut
        );

        // Enregistrement des informations du formateur dans Firestore
        await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(userCredential.user!.uid)
            .set({
          'prenom': prenom,
          'nom': nom,
          'email': email,
          'role': 'MANAGER', // Rôle par défaut
          'created_at': Timestamp.now(),
          'admin_id': adminId, // ID du formateur connecté
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formateur ajouté avec succès')),
        );

        // Réinitialiser le formulaire après l'enregistrement
        formKey.currentState?.reset();
      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs d'authentification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  //Bouton pour ajouter une réunion
  Future<void> btnAjouterReunion(
      GlobalKey<FormState> formKey,
      BuildContext context,
      Reunion nouvelleReunion) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();


      // Appel au service pour ajouter la réunion
      try {
        await reunionService.ajouterReunion(nouvelleReunion, context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réunion ajoutée avec succès !')),
        );
        //Navigator.pop(context); // Retour à l'écran précédent
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de l\'ajout de la réunion.')),
        );
      }
    }
  }

  //Bouton pour uploader  les documents
  Future<List<String>> selectionnerEtUploaderFichier(
      BuildContext context, List<String> documents) async {

    String nomFichier = await fichiersService.selectionnerFichier();

    if (nomFichier.isNotEmpty && nomFichier != 'Aucun fichier selectionné') {
      // Si un fichier a bien été sélectionné et uploadé
      documents.add(nomFichier); // Ajouter le nom du fichier à la liste

      // Mise à jour de l'interface
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fichier $nomFichier uploadé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      return documents;
    } else if (nomFichier == 'Aucun fichier selectionné') {
      // Si aucun fichier n'a été sélectionné
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun fichier sélectionné'),
          backgroundColor: Colors.orange,
        ),
      );
      return documents;
    } else {
      // En cas d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $nomFichier'),
          backgroundColor: Colors.red,
        ),
      );
      return documents;
    }
  }

  //Bouton pour la deconnexion
  void boutonDeconnexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                authService.deconnexion(context); // Déconnexion et retour à la page de connexion
              },
            ),
          ],
        );
      },
    );
  }

  //Bouton pour changer le mot de passe
  Future<void> changePassword(
      BuildContext context,
      String oldPasswordController,
      String newPasswordController,
      String confirmPasswordController,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Authentifier l'utilisateur avec l'ancien mot de passe
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController,
      );

      // Re-authentification de l'utilisateur
      await user.reauthenticateWithCredential(cred);

      // Vérifier si le nouveau mot de passe et sa confirmation sont identiques
      if (newPasswordController != confirmPasswordController) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
        );
        return;
      }

      // Mettre à jour le mot de passe dans Firebase Authentication
      await user.updatePassword(newPasswordController);

      // Mettre à jour le mot de passe dans Firestore si nécessaire
      await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).update({
        'password': newPasswordController, // Enregistrer le mot de passe chiffré si nécessaire
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
      );

      // Retour à la page précédente
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.message}')),
      );
    }
  }

  // Bouton pour ajouter une équipe
  void boutonAjoutEquipe(GlobalKey<FormState> formKey,
      BuildContext context, Equipe nouvelleEquipe) async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return; // Si le formulaire n'est pas valide, on arrête ici.

    formKey.currentState?.save(); // Sauvegarde les valeurs du formulaire

    try {
      // Appeler le service pour ajouter l'équipe
      await EquipeService().ajouterEquipe(nouvelleEquipe);
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Équipe ajoutée avec succès !'))
      );
    } catch (e) {
      // Afficher un message d'erreur si l'ajout échoue
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'équipe : $e'))
      );
    }
  }

  // Bouton pour ajouter un manager
  Future<void> boutonAjouterManager(GlobalKey<FormState> formKey,
      BuildContext context, Utilisateur manager) async {
    final isValid = formKey.currentState?.validate();
    if (isValid != null && isValid) {
      formKey.currentState?.save();
      try {
        // Récupérer l'ID de l'utilisateur connecté
        String? adminId = FirebaseAuth.instance.currentUser?.uid;
        manager.userMere = adminId.toString();


        // Création de l'utilisateur apprenant dans Firebase Authentication avec un mot de passe par défaut
        UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
          email: manager.email,
          password: '12345678', // Mot de passe par défaut
        );

        // Enregistrement des informations du manager dans Firestore
        UtilisateurService().ajouterUtilisateur(manager);

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manager ajouté avec succès')),
        );

        // Réinitialiser le formulaire après l'enregistrement
        formKey.currentState?.reset();
      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs d'authentification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}
