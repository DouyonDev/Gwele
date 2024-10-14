import 'package:cloud_firestore/cloud_firestore.dart';

class Equipe {
  String id;
  String nom;
  String leaderId; // ID du leader
  String? secondId; // ID du second (peut être nul)
  String managerId;
  List<String> membres; // Liste des IDs des membres de l'équipe
  List<String> reunions; // Liste des IDs des réunions
  DateTime? dateCreation; // Date de création de l'équipe

  // Constructeur
  Equipe({
    required this.id,
    required this.nom,
    required this.leaderId,
    this.secondId,
    required this.managerId,
    required this.membres,
    required this.reunions, // Initialisation des réunions
    this.dateCreation,
  });

  // Méthode pour créer une équipe depuis un DocumentSnapshot Firestore
  factory Equipe.fromDocument(Map<String, dynamic> data, String docId) {
    return Equipe(
      id: docId,
      nom: data['nom'] ?? '', // Valeur par défaut si le champ n'existe pas
      leaderId: data['leaderId'] ?? '', // Valeur par défaut si le champ n'existe pas
      secondId: data['secondId'], // Peut être null
      managerId: data['managerId'] ?? '', // Valeur par défaut si le champ n'existe pas
      membres: data['membres'] != null ? List<String>.from(data['membres']) : [], // Si pas de membres, retourne une liste vide
      reunions: data['reunions'] != null ? List<String>.from(data['reunions']) : [], // Si pas de réunions, retourne une liste vide
      dateCreation: data['dateCreation'] != null
          ? (data['dateCreation'] as Timestamp).toDate()
          : null, // Conversion Timestamp Firestore en DateTime
    );
  }

  // Méthode pour convertir une instance d'Equipe en un format utilisable par Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'leaderId': leaderId,
      'secondId': secondId,
      'managerId': managerId,
      'membres': membres,
      'reunions': reunions, // Ajout des réunions
      'dateCreation': dateCreation != null ? Timestamp.fromDate(dateCreation!) : null,
    };
  }
}
