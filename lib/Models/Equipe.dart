import 'package:cloud_firestore/cloud_firestore.dart';

class Equipe {
  String id;
  String nom;
  String leaderId; // ID du leader
  String? secondId; // ID du second (peut être nul)
  String managerId;
  List<String> membres; // Liste des IDs des membres de l'équipe
  DateTime? dateCreation; // Date de création de l'équipe

  // Constructeur
  Equipe({
    required this.id,
    required this.nom,
    required this.leaderId,
    this.secondId,
    required this.managerId,
    required this.membres,
    this.dateCreation,
  });

  // Méthode pour créer une équipe depuis un DocumentSnapshot Firestore
  factory Equipe.fromDocument(DocumentSnapshot doc) {
    return Equipe(
      id: doc.id,
      nom: doc['nom'] ?? '', // Valeur par défaut si le champ n'existe pas
      leaderId: doc['leaderId'] ?? '', // Valeur par défaut
      secondId: doc['secondId'], // Peut être null
      managerId: doc['secondId'] ?? '', // Peut être null
      membres: doc['membres'] != null
          ? List<String>.from(doc['membres'])
          : [], // Si pas de membres, retourne une liste vide
      dateCreation: (doc['dateCreation'] != null)
          ? (doc['dateCreation'] as Timestamp).toDate()
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
      'dateCreation': dateCreation != null ? Timestamp.fromDate(dateCreation!) : null,
    };
  }
}
