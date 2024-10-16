import 'package:cloud_firestore/cloud_firestore.dart';

class Facture {
  String id;
  String clientId;
  String numeroFacture; // Saisie par l'utilisateur
  String description;
  double montant;
  DateTime dateEmission;
  DateTime dateEcheance;
  bool estPaye;
  List<String> idPaiements; // Liste des IDs de paiements associés

  Facture({
    required this.id,
    required this.clientId,
    required this.numeroFacture, // Numéro de facture à saisir
    required this.description,
    required this.montant,
    required this.dateEmission,
    required this.dateEcheance,
    this.estPaye = false,
    List<String>? idPaiements, // Paramètre optionnel
  }) : idPaiements = idPaiements ?? []; // Initialise la liste

  factory Facture.fromMap(Map<String, dynamic> data, String documentId) {
    return Facture(
      id: documentId,
      clientId: data['clientId'] ?? '',
      numeroFacture: data['numeroFacture'] ?? '',
      description: data['description'] ?? 'Aucune description',
      montant: data['montant'] != null ? (data['montant'] as num).toDouble() : 0.0,
      dateEmission: (data['dateEmission'] as Timestamp).toDate(),
      dateEcheance: (data['dateEcheance'] as Timestamp).toDate(),
      estPaye: data['estPaye'] ?? false,
      idPaiements: List<String>.from(data['idPaiements'] ?? []), // Récupère la liste des IDs de paiements
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'numeroFacture': numeroFacture,
      'description': description,
      'montant': montant,
      'dateEmission': dateEmission,
      'dateEcheance': dateEcheance,
      'estPaye': estPaye,
      'idPaiements': idPaiements, // Inclut la liste des IDs de paiements
    };
  }
}
