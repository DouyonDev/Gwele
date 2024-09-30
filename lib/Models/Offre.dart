class Offre {
  final String id; // Identifiant unique de l'offre
  final String titre; // Titre de l'offre
  final String description; // Description de l'offre
  final DateTime dateLimite; // Date limite pour postuler
  final String statut; // Statut (en attente, soumise, expirée)
  final List<String> documents; // Documents attachés à l'offre
  final String soumisPar; // Personne qui a soumis l'offre
  final bool isExpired; // Indicateur si l'offre a expiré

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
