import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Tache.dart';

class TacheService {
  final CollectionReference tacheCollection =
      FirebaseFirestore.instance.collection('taches');

  // Ajouter une tâche
  Future<void> ajouterTache(Tache tache) async {
    try {
      await tacheCollection.doc(tache.id).set({
        'titre': tache.titre,
        'description': tache.description,
        'assigneA': tache.assigneA,
        'dateLimite': tache.dateLimite.toIso8601String(),
        'statut': tache.statut,
        'priorite': tache.priorite,
        'commentaires': tache.commentaires,
        'documents': tache.documents,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de la tâche: $e');
      throw e; // Propager l'erreur pour la gestion à un niveau supérieur
    }
  }

  // Récupérer une liste de tâches
  Stream<List<Tache>> listeTaches() {
    try {
      return tacheCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Tache(
            id: doc.id,
            titre: doc['titre'],
            description: doc['description'],
            assigneA: doc['assigneA'],
            dateLimite: DateTime.parse(doc['dateLimite']),
            statut: doc['statut'],
            priorite: doc['priorite'],
            commentaires: List<String>.from(doc['commentaires']),
            documents: List<String>.from(doc['documents']),
          );
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des tâches: $e');
      rethrow; // Propager l'erreur
    }
  }

  // Mise à jour d'une tâche
  Future<void> mettreAJourTache(Tache tache) async {
    try {
      await tacheCollection.doc(tache.id).update({
        'titre': tache.titre,
        'description': tache.description,
        'assigneA': tache.assigneA,
        'dateLimite': tache.dateLimite.toIso8601String(),
        'statut': tache.statut,
        'priorite': tache.priorite,
        'commentaires': tache.commentaires,
        'documents': tache.documents,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la tâche: $e');
      throw e;
    }
  }

  // Suppression d'une tâche
  Future<void> supprimerTache(String id) async {
    try {
      await tacheCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression de la tâche: $e');
      throw e;
    }
  }
}
