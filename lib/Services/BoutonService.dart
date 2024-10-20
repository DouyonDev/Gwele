import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gwele/Models/Client.dart';
import 'package:gwele/Models/Equipe.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/ajout_ordre_du_jour.dart';
import 'package:gwele/Screens/Widgets/message_modale_erreur.dart';
import 'package:gwele/Services/ClientService.dart';
import 'package:gwele/Services/NotificationService.dart';

import '../Screens/Widgets/message_modale.dart';
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

  // Bouton pour la connexion
  Future<void> boutonConnexion(
      GlobalKey<FormState> formKey, String email, String password, BuildContext context) async {
    final isValid = formKey.currentState?.validate();

    if (isValid != null && isValid) {
      formKey.currentState?.save();

      // Affichage de l'indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false, // Empêche de fermer la fenêtre pendant le chargement
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        Utilisateur? utilisateur =
        await authService.connexionAvecPassword(email, password, context);

        // Ferme l'indicateur de chargement
        //Navigator.of(context).pop();

        if (utilisateur != null) {
          // Affiche un message de succès si la connexion est réussie
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
        // Ferme l'indicateur de chargement
        Navigator.of(context).pop();

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

  //Bouton pour enregistrer un manager
  Future<void> BtnAjouterClient(GlobalKey<FormState> formKey,
      BuildContext context, Client client) async {
    final isValid = formKey.currentState?.validate();
    if (isValid != null && isValid) {
      formKey.currentState?.save();
      try {
        // Récupérer l'ID du formateur connecté
        final comptableId = FirebaseAuth.instance.currentUser?.uid;

        ClientService().ajouterClient(client);

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client ajouté avec succès')),
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

      final user = await AuthService().idUtilisateurConnecte();
      nouvelleReunion.lead = (user)!;
      nouvelleReunion.participants.add(user);
      // Appel au service pour ajouter la réunion
      try {
        await reunionService.ajouterReunion(nouvelleReunion, context);
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const MessageModale(
                title: "Success",
                content: "Votre réunion a été programmée"
            );
          },
        );

        // Récupérer les tokens de notification à partir de la liste des participants
        //List<String> notificationTokens = await NotificationService().getNotificationTokens(nouvelleReunion.participants);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const MessageModale(
                title: "Erreur",
                content: "Erreur lors de l'ajout de la réunion. \n Veuillez recommencer"
            );
          },
        );
      }
    }
  }

  // Sélectionner un fichier et l'ajouter à la liste
  Future<List<File>> selectionnerEtAfficherFichier(
      BuildContext context,setState, List<File> documents) async {

    File? fichier = await FichiersService().selectionnerFichier();
    if (fichier != null) {
      setState(() {
        documents.add(fichier);
      });
    }

    Future<File?> selectionnerFichier() async {

      File? fichier = await FichiersService().selectionnerFichier();
      return fichier;
    }
      return documents;
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
                AuthService().deconnexion(context); // Déconnexion et retour à la page de connexion
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
  void boutonAjoutEquipe(GlobalKey<FormState> formKey, BuildContext context, Equipe nouvelleEquipe) async {
    final isValid = formKey.currentState?.validate() ?? false;

    // Vérification si le leader est sélectionné
    if (nouvelleEquipe.leaderId == null || nouvelleEquipe.leaderId == "") {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const MessageModaleErreur(
              title: "Erreur",
              content: "Veuillez choisir un leader"
          );
        },
      );
      return; // Arrête la fonction si aucune sélection de leader
    }

    // Vérification si l'adjoint est sélectionné
    else if (nouvelleEquipe.secondId == null || nouvelleEquipe.secondId == "") {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const MessageModaleErreur(
              title: "Erreur",
              content: "Veuillez choisir un adjoint"
          );
        },
      );
      return; // Arrête la fonction si aucune sélection d'adjoint
    }

    // Validation du formulaire
    if (!isValid) return;

    formKey.currentState?.save(); // Sauvegarde les valeurs du formulaire

    try {
      // Récupère l'ID du manager actuellement connecté
      final managerId = await AuthService().idUtilisateurConnecte();
      nouvelleEquipe.managerId = managerId!;

      // Appelle le service pour ajouter l'équipe
      await EquipeService().ajouterEquipe(nouvelleEquipe);

      // Affiche un message de succès via un Dialog ou autre
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return MessageModale(
            title: "Succès",
            content: 'Équipe ${nouvelleEquipe.nom} ajoutée avec succès !',
          );
        },
      );
    } catch (e) {
      // Affiche un message d'erreur dans un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de l\'équipe : $e')),
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
        String? tokenMessaging = await FirebaseMessaging.instance.getToken();
        manager.userMere = adminId.toString();
        manager.notificationToken = tokenMessaging.toString();


        // Création de l'utilisateur manager dans Firebase Authentication avec un mot de passe par défaut
        UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
          email: manager.email,
          password: '12345678', // Mot de passe par défaut
        );

        manager.id = userCredential.user!.uid;
        // Enregistrement des informations du manager dans Firestore
        UtilisateurService().ajouterUtilisateur(manager);

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur ajouté avec succès')),
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

  Future<void> boutonAjouterMembre(GlobalKey<FormState> formKey,
      BuildContext context, Utilisateur membre, Equipe equipe) async {
    final isValid = formKey.currentState?.validate();
    if (isValid != null && isValid) {
      formKey.currentState?.save();
      try {
        // Récupérer l'ID de l'utilisateur connecté
        String? adminId = FirebaseAuth.instance.currentUser?.uid;
        String? tokenMessaging = await FirebaseMessaging.instance.getToken();
        membre.userMere = adminId.toString();
        membre.notificationToken = tokenMessaging.toString();


        // Création de l'utilisateur manager dans Firebase Authentication avec un mot de passe par défaut
        UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
          email: membre.email,
          password: '12345678', // Mot de passe par défaut
        );

        equipe.membres.add(userCredential.user!.uid);
        EquipeService().mettreAJourEquipe(equipe);

        membre.id = userCredential.user!.uid;
        // Enregistrement des informations du manager dans Firestore
        UtilisateurService().ajouterUtilisateur(membre);

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur ajouté avec succès')),
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

  // Bouton pour ajouter un ordre du jour
  void boutonAjouterOrdreDuJour(BuildContext context, Function setState,List<String> ordreDuJour) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AjouterOrdreDuJour(
          onOrdreDuJourAjoute: (String id) {
            // Utilisez setState pour mettre à jour la liste des ordres du jour
            setState(() {
              // Ajoutez l'ID à la liste ordreDuJour ici
              ordreDuJour.add(id);
            });

            // Affiche une notification pour confirmer l'ajout
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ordre du jour ajouté avec l\'ID : $id')),
            );
          },
        );
      },
    );
  }



}

