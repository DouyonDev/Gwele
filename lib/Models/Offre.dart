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
    required this.isExpired,
  });
}
