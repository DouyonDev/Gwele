class OrdreDuJour {
  String id; // UUID
  String titre;
  String description;
  String statut; // "en cours", "terminé", "annulé"
  Duration duree; // Durée de l'ordre du jour
  List<String> decisionsIds; // Liste d'IDs des décisions

  OrdreDuJour({
    required this.id,
    required this.titre,
    required this.description,
    required this.statut,
    required this.duree,
    required this.decisionsIds, // Les décisions sont maintenant des IDs
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'statut': statut,
      'duree': duree.inMinutes,
      'decisionsIds': decisionsIds, // Stockage des IDs
    };
  }

  factory OrdreDuJour.fromMap(Map<String, dynamic> map) {
    return OrdreDuJour(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
      statut: map['statut'],
      duree: Duration(minutes: map['duree']),
      decisionsIds: List<String>.from(map['decisionsIds']), // Récupération des IDs
    );
  }
}
