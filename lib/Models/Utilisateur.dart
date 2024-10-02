class Utilisateur {
  String id;
  String nom;
  String prenom;
  String role;
  String email;
  String imageUrl;
  String userMere;
  String notificationToken; // Token FCM pour les notifications
  List<String> tachesAssignees;
  List<String> reunions;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.email,
    required this.imageUrl,
    required this.userMere,
    required this.notificationToken,
    required this.tachesAssignees,
    required this.reunions,
  });

  // Méthode pour convertir un document Firestore en instance de Utilisateur
  factory Utilisateur.fromDocument(Map<String, dynamic> doc, String docId) {
    return Utilisateur(
      id: docId,
      nom: doc['nom'] ?? '',
      prenom: doc['prenom'] ?? '',
      role: doc['role'] ?? '',
      email: doc['email'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
      userMere: doc['userMere'] ?? '',
      notificationToken: doc['notificationToken'] ?? '',
      tachesAssignees: List<String>.from(doc['tachesAssignees'] ?? []),
      reunions: List<String>.from(doc['reunions'] ?? []),
    );
  }


  // Méthode pour convertir une instance d'Utilisateur en format Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'role': role,
      'email': email,
      'userMere': userMere,
      'imageUrl': imageUrl,
      'notificationToken': notificationToken,
      'tachesAssignees': tachesAssignees,
      'reunions': reunions,
    };
  }
}
