import 'package:flutter/material.dart';
import 'package:gwele/Services/UtilsService.dart';

class Reunion {
  String id;
  String titre;
  String description;
  String statut;
  DateTime dateReunion;
  TimeOfDay heureDebut;
  TimeOfDay heureFin;
  List<String> participants;
  String lieu;
  bool isCompleted;
  String lead;
  String rapporteur;
  List<String> ordreDuJour;
  List<String> tachesAssignees;
  List<String> documents;

  Reunion({
    required this.id,
    required this.titre,
    required this.description,
    required this.statut,
    required this.dateReunion,
    required this.heureDebut,
    required this.heureFin,
    required this.participants,
    required this.lieu,
    required this.isCompleted,
    required this.lead,
    required this.rapporteur,
    required this.ordreDuJour,
    required this.tachesAssignees,
    required this.documents,
  });

  // Méthode pour convertir un document Firestore en instance de Reunion
  factory Reunion.fromDocument(Map<String, dynamic> doc, String docId) {
    return Reunion(
      id: docId,
      titre: doc['titre'] ?? '',
      description: doc['description'] ?? '',
      statut: doc['statut'] ?? '',
      dateReunion: DateTime.parse(doc['dateReunion'] ?? DateTime.now().toIso8601String()),
      heureDebut: TimeOfDay(
        hour: (doc['heureDebut'] as Map<String, dynamic>?)?['hour'] ?? 0,
        minute: (doc['heureDebut'] as Map<String, dynamic>?)?['minute'] ?? 0,
      ),
      heureFin: TimeOfDay(
        hour: (doc['heureFin'] as Map<String, dynamic>?)?['hour'] ?? 0,
        minute: (doc['heureFin'] as Map<String, dynamic>?)?['minute'] ?? 0,
      ),
      participants: List<String>.from(doc['participants'] ?? []),
      lieu: doc['lieu'] ?? '',
      isCompleted: doc['isCompleted'] ?? false,
      lead: doc['lead'] ?? '',
      rapporteur: doc['rapporteur'] ?? '',
      ordreDuJour: List<String>.from(doc['ordreDuJour'] ?? []),
      tachesAssignees: List<String>.from(doc['tachesAssignees'] ?? []),
      documents: List<String>.from(doc['documents'] ?? []),
    );
  }

  // Méthode pour convertir une instance de Reunion en format Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'statut': statut,
      'dateReunion': UtilsService().formatDate(dateReunion),
      'heureDebut': {'hour': heureDebut.hour, 'minute': heureDebut.minute},
      'heureFin': {'hour': heureFin.hour, 'minute': heureFin.minute},
      'participants': participants,
      'lieu': lieu,
      'isCompleted': isCompleted,
      'lead': lead,
      'rapporteur': rapporteur,
      'ordreDuJour': ordreDuJour,
      'tachesAssignees': tachesAssignees,
      'documents': documents,
    };
  }
}
