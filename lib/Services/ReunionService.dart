import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Services/push_notification_service.dart';

import 'UtilisateurService.dart';


class ReunionService {
  final CollectionReference reunionCollection =
      FirebaseFirestore.instance.collection('reunions');

  //FOnction pour ajouter une réunion
  Future<void> ajouterReunion(Reunion reunion, BuildContext context) async {
    try {
      // Ajout de la réunion dans la collection Firestore
      DocumentReference docRef = await reunionCollection.add(reunion.toMap());

      // Mise à jour de l'objet Reunion avec l'ID généré
      reunion.id = docRef.id;

      // Boucle pour envoyer une notification à chaque participant
      for (var participant in reunion.participants) {
        Utilisateur? participantInfo = await UtilisateurService().utilisateurParId(participant);
        // Boucle pour envoyer une notification à chaque participant
        await PushNotificationService.sendNotification(
          title: "Nouvelle réunion",
          body: "Vous êtes invité(e) à une nouvelle réunion",
          token: participantInfo!.notificationToken, // Assurez-vous que chaque participant a un tokenFirebase
          contextType: "reunion",
          contextData: reunion.id, // Utilisation de l'ID de la réunion comme contextData
        );
      }

      print('Reunion ajoutée avec succès avec l\'ID: ${reunion.id}');
      print('Notifications envoyées à tous les participants');
    } catch (e) {
      print('Erreur lors de l\'ajout de la réunion ou de l\'envoi des notifications: $e');
      throw e; // Relance l'erreur pour être gérée au niveau supérieur
    }
  }



  // Récupérer une liste de réunions
  Stream<List<Reunion>> listeReunions() {
    try {
      return reunionCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return Reunion(
            id: doc.id,
            titre:
                data['titre'] ?? 'Sans titre', // Valeur par défaut si manquant
            description: data['description'] ??
                'Pas de description', // Valeur par défaut
            statut: data['statut'] ?? 'En attente', // Valeur par défaut si statut
            dateReunion: data['dateReunion'] != null
                ? DateTime.parse(data['dateReunion'])
                : DateTime.now(), // Fallback sur la date actuelle si manquant
            heureDebut: data['heureDebut'] != null
                ? _parseTimeOfDay(data['heureDebut'])
                : const TimeOfDay(hour: 0, minute: 0), // Valeur par défaut
            heureFin: data['heureFin'] != null
                ? _parseTimeOfDay(data['heureFin'])
                : const TimeOfDay(hour: 23, minute: 59), // Valeur par défaut
            participants: data['participants'] != null
                ? List<String>.from(data['participants'])
                : [], // Liste vide si manquant
            lieu: data['lieu'] ??
                'Lieu non défini', // Valeur par défaut si manquant
            isCompleted: data['isCompleted'] ?? false, // Faux par défaut
            lead: data['lead'] ?? 'Non défini', // Valeur par défaut si manquant
            rapporteur: data['rapporteur'] ?? 'Non défini', // Valeur par défaut si manquant
            ordreDuJour: data['ordreDuJour'] != null
                ? List<String>.from(data['ordreDuJour'])
                : [], // Liste vide si manquant
            tachesAssignees: [], // Gérer séparément si nécessaire
            documents: [],
          );
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des réunions: $e');
      rethrow;
    }
  }

  // Méthode pour obtenir la liste des réunions
  Future<List<Reunion>> obtenirLesReunions() async {
    try {
      // Récupérer la collection 'reunions'
      QuerySnapshot snapshot = await reunionCollection.get();

      // Convertir les documents en instances de Reunion
      return snapshot.docs.map((doc) {
        return Reunion.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des réunions: $e");
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

// Fonction pour convertir une chaîne "HH:mm" en TimeOfDay
  TimeOfDay _parseTimeOfDay(String time) {
    final format = time.split(":");
    final hour = int.parse(format[0]);
    final minute = int.parse(format[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Mise à jour d'une réunion
  Future<void> mettreAJourReunion(Reunion reunion) async {
    try {
      await reunionCollection.doc(reunion.id).update({
        'titre': reunion.titre,
        'description': reunion.description,
        'statut': reunion.statut,
        'dateReunion': reunion.dateReunion.toIso8601String(),
        'participants': reunion.participants,
        'lieu': reunion.lieu,
        'isCompleted': reunion.isCompleted,
        'lead': reunion.lead,
        'rapporteur': reunion.rapporteur,
        'ordreDuJour': reunion.ordreDuJour,
        'tachesAssignees': reunion.tachesAssignees,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la réunion: $e');
      throw e;
    }
  }

  // Suppression d'une réunion
  Future<void> supprimerReunion(String id) async {
    try {
      await reunionCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression de la réunion: $e');
      throw e;
    }
  }

  Future<QuerySnapshot> LesParticipantsReunion(String reunionId) async {
    // Récupérer le document de la réunion par son ID
    DocumentSnapshot reunionDoc = await FirebaseFirestore.instance
        .collection('reunions')
        .doc(reunionId)
        .get();

    if (!reunionDoc.exists) {
      throw Exception("La réunion n'existe pas.");
    }

    // Récupérer la liste des IDs des participants (assumée comme un champ 'participants')
    List<dynamic> participantIds = reunionDoc['participants'] ?? [];

    if (participantIds.isEmpty) {
      throw Exception("Aucun participant trouvé.");
    }

    // Récupérer les utilisateurs en fonction de leurs IDs
    return await FirebaseFirestore.instance
        .collection('utilisateurs')
        .where(FieldPath.documentId, whereIn: participantIds)
        .get();
  }

  // Récupérer la liste des ordres du jour pour une réunion donnée
  Future<List<String>> obtenirOrdresDuJour(String reunionId) async {
    try {
      // Récupérer le document de la réunion par son ID
      DocumentSnapshot reunionDoc = await reunionCollection.doc(reunionId).get();

      if (!reunionDoc.exists) {
        throw Exception("La réunion n'existe pas.");
      }

      // Récupérer la liste des ordres du jour (assumée comme un champ 'ordreDuJour')
      List<dynamic> ordresDuJour = reunionDoc['ordreDuJour'] ?? [];

      // Transformer en List<String>
      return List<String>.from(ordresDuJour);
    } catch (e) {
      print("Erreur lors de la récupération des ordres du jour : $e");
      throw e;
    }
  }



}
