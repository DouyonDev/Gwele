class
Client {
  String id;
  String prenom;
  String nom;
  String email;
  String adresse;
  String telephone;
  List<String> idFactures; // Liste des IDs des factures associées à ce client

  Client({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.adresse,
    required this.telephone,
    required this.idFactures,
  });

  // Convertir un objet Client en Map pour l'envoyer à Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'adresse': adresse,
      'telephone': telephone,
      'idFactures': idFactures,
    };
  }

  // Créer un Client à partir d'une Map
  factory Client.fromMap(Map<String, dynamic> map, String id) {
    return Client(
      id: map['id'] ?? '',
      prenom: map['prenom'] ?? '',
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      idFactures: List<String>.from(map['idFactures'] ?? []),
    );
  }
}
