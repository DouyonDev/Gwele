import '../Services/UtilsService.dart';

class Offre {
  String id; // Identifiant unique de l'offre
  String titre; // Titre de l'offre
  String description; // Description de l'offre
  DateTime dateLimite; // Date limite pour postuler
  String statut; // Statut (en attente, soumise, expirée)
  List<String> documents; // Documents attachés à l'offre
  String soumisPar; // Personne qui a soumis l'offre
  bool isExpired; // Indicateur si l'offre a expiré

  Offre({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateLimite,
    required this.statut,
    required this.documents,
    required this.soumisPar,
    bool? isExpired,
  }) : isExpired = isExpired ?? DateTime.now().isAfter(dateLimite);

  // Méthode pour convertir une instance Offre en un format Firestore (Map<String, dynamic>)
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'dateLimite': UtilsService().formatDate(dateLimite), // Convertir DateTime en String pour Firestore
      'statut': statut,
      'documents': documents,
      'soumisPar': soumisPar,
      'isExpired': isExpired,
    };
  }

  // Méthode pour convertir un document Firestore en instance de Offre
  factory Offre.fromFirestore(Map<String, dynamic> data, String docId) {
    return Offre(
      id: docId, // Utiliser l'id du document Firestore
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      dateLimite: DateTime.parse(data['dateLimite']), // Convertir String en DateTime
      statut: data['statut'] ?? 'en attente',
      documents: List<String>.from(data['documents'] ?? []),
      soumisPar: data['soumisPar'] ?? '',
      isExpired: data['isExpired'] ?? false, // Utiliser false par défaut si non défini
    );
  }
}
