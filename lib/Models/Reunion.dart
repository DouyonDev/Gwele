import 'package:flutter/material.dart';

class Reunion {
  final String id;
  final String titre;
  final String description;
  final DateTime dateReunion;
  final TimeOfDay heureDebut;
  final TimeOfDay heureFin;
  final List<String> participants;
  final String lieu;
  final bool isCompleted;
  final String lead;
  final List<String> decisions;
  final List<String> tachesAssignees;
  final List<String> documents;

  Reunion({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateReunion,
    required this.heureDebut,
    required this.heureFin,
    required this.participants,
    required this.lieu,
    required this.isCompleted,
    required this.lead,
    required this.decisions,
    required this.tachesAssignees,
    required this.documents,
  });

  // Méthode pour convertir un document Firestore en instance de Reunion
  factory Reunion.fromDocument(Map<String, dynamic> doc, String docId) {
    return Reunion(
      id: docId,
      titre: doc['titre'] ?? '',
      description: doc['description'] ?? '',
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
      decisions: List<String>.from(doc['decisions'] ?? []),
      tachesAssignees: List<String>.from(doc['tachesAssignees'] ?? []),
      documents: List<String>.from(doc['documents'] ?? []),
    );
  }

  // Méthode pour convertir une instance de Reunion en format Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'dateReunion': dateReunion.toIso8601String(),
      'heureDebut': {'hour': heureDebut.hour, 'minute': heureDebut.minute},
      'heureFin': {'hour': heureFin.hour, 'minute': heureFin.minute},
      'participants': participants,
      'lieu': lieu,
      'isCompleted': isCompleted,
      'lead': lead,
      'decisions': decisions,
      'tachesAssignees': tachesAssignees,
      'documents': documents,
    };
  }
}
