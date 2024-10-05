import '../Services/UtilsService.dart';

class Tache {
  String id;
  String titre;
  String description;
  String assigneA;
  String assignePar;
  DateTime dateLimite;
  String statut;
  String priorite;
  List<String> commentaires;

  Tache({
    required this.id,
    required this.titre,
    required this.description,
    required this.assigneA,
    required this.assignePar,
    required this.dateLimite,
    required this.statut,
    required this.priorite,
    required this.commentaires,
  });

  // Méthode pour convertir un document Firestore en instance de Tache
  factory Tache.fromDocument(Map<String, dynamic> doc, String docId) {
    return Tache(
      id: docId,
      titre: doc['titre'] ?? '',
      description: doc['description'] ?? '',
      assigneA: doc['assigneA'] ?? '',
      assignePar: doc['assignePar'] ?? '',
      dateLimite: DateTime.parse(doc['dateLimite'] ?? DateTime.now().toIso8601String()),
      statut: doc['statut'] ?? '',
      priorite: doc['priorite'] ?? '',
      commentaires: List<String>.from(doc['commentaires'] ?? []),
    );
  }

  // Méthode pour convertir une instance de Tache en format Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'assigneA': assigneA,
      'assignePar': assignePar,
      'dateLimite': UtilsService().formatDate(dateLimite),
      'statut': statut,
      'priorite': priorite,
      'commentaires': commentaires,
    };
  }
}
