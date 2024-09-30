import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/Reunion.dart';

class ReunionService {
  final CollectionReference reunionCollection =
      FirebaseFirestore.instance.collection('reunions');

  //Ajouter reunion
  Future<void> ajouterReunion(Reunion reunion, BuildContext context) async {
    try {
      await reunionCollection.add({
        'titre': reunion.titre,
        'description': reunion.description,
        'dateReunion': reunion.dateReunion.toIso8601String(),
        'heureDebut': reunion.heureDebut.format(
            context), // Utilisation de format pour obtenir la chaîne d'heure
        'heureFin': reunion.heureFin.format(
            context), // Utilisation de format pour obtenir la chaîne d'heure
        'participants': reunion.participants,
        'lieu': reunion.lieu,
        'isCompleted': reunion.isCompleted,
        'lead': reunion.lead,
        'decisions': reunion.decisions,
        'tachesAssignees':
            reunion.tachesAssignees.map((tache) => tache.id).toList(),
        'documents': reunion.documents,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de la réunion: $e');
      throw e;
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
            decisions: data['decisions'] != null
                ? List<String>.from(data['decisions'])
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
        'dateReunion': reunion.dateReunion.toIso8601String(),
        'participants': reunion.participants,
        'lieu': reunion.lieu,
        'isCompleted': reunion.isCompleted,
        'lead': reunion.lead,
        'decisions': reunion.decisions,
        'tachesAssignees':
            reunion.tachesAssignees.map((tache) => tache.id).toList(),
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
}
