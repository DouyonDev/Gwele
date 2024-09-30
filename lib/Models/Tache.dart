class Tache {
  final String id; // Identifiant unique de la tâche
  final String titre; // Titre de la tâche
  final String description; // Description de la tâche
  final String assigneA; // Personne à qui la tâche est assignée
  final DateTime dateLimite; // Date limite pour terminer la tâche
  final String statut; // Statut (en attente, en cours, terminé)
  final String priorite; // Priorité (haute, moyenne, basse)
  final List<String> commentaires; // Liste des commentaires
  final List<String> documents; // Liste des fichiers attachés

  Tache({
    required this.id,
    required this.titre,
    required this.description,
    required this.assigneA,
    required this.dateLimite,
    required this.statut,
    required this.priorite,
    required this.commentaires,
    required this.documents,
  });
}
