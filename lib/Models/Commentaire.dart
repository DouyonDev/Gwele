class Commentaire {
  String id;
  String reunionId; // Lien avec la réunion
  String auteurId; // ID de l'auteur du commentaire
  String? ordreDuJour; // L'ordre du jour concerné par le commentaire
  String contenu; // Le contenu du commentaire
  DateTime dateCommentaire; // Date du commentaire

  Commentaire({
    required this.id,
    required this.reunionId,
    required this.auteurId,
    required this.ordreDuJour,
    required this.contenu,
    required this.dateCommentaire,
  });

  // Convertir un Commentaire en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reunionId': reunionId,
      'auteurId': auteurId,
      'ordreDuJour': ordreDuJour,
      'contenu': contenu,
      'dateCommentaire': dateCommentaire.toIso8601String(),
    };
  }

  // Créer un Commentaire depuis un Map (ex: Firestore)
  factory Commentaire.fromMap(Map<String, dynamic> map, String documentId) {
    return Commentaire(
      id: documentId,
      reunionId: map['reunionId'] ?? '',
      auteurId: map['auteurId'] ?? '',
      ordreDuJour: map['ordreDuJour'] ?? '',
      contenu: map['contenu'] ?? '',
      dateCommentaire: map['dateCommentaire'] != null
          ? DateTime.parse(map['dateCommentaire'])
          : DateTime.now(),
    );
  }
}
