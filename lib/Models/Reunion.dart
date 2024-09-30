import 'package:flutter/material.dart';
import 'Tache.dart';

class Reunion {
  final String id; // Identifiant unique de la réunion
  final String titre; // Titre de la réunion
  final String description; // Description de la réunion
  final DateTime dateReunion; // Date prévue pour la réunion
  final TimeOfDay heureDebut; // Heure de début de la réunion
  final TimeOfDay heureFin; // Heure de fin de la réunion
  final List<String> participants; // Liste des identifiants des participants
  final String lieu; // Lieu de la réunion (physique ou en ligne)
  final bool isCompleted; // Indique si la réunion est terminée
  final String lead; // Personne qui dirige la réunion
  final List<String> decisions; // Liste des décisions prises
  final List<Tache> tachesAssignees; // Tâches assignées pendant la réunion
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
}
