import 'package:flutter/material.dart';

class OrdreDuJour {
  String id; // UUID
  String titre;
  String description;
  String statut; // Peut être "en cours", "terminé", "annulé"
  String decisions;

  OrdreDuJour({
    required this.id,
    required this.titre,
    required this.description,
    required this.statut,
    this.decisions = '',
  });

  // Méthode pour convertir l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'statut': statut,
      'decisions': decisions,
    };
  }

  // Méthode pour créer un Ordre du Jour à partir d'une Map
  factory OrdreDuJour.fromMap(Map<String, dynamic> map) {
    return OrdreDuJour(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
      statut: map['statut'],
      decisions: map['decisions'] ?? '',
    );
  }

  // Méthode pour ajouter une décision à l'ordre du jour
  void ajouterDecision(String decision) {
    if (decisions.isNotEmpty) {
      decisions += ', ';
    }
    decisions += decision;
  }
}
