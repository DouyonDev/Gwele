import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/Tache.dart';

class TacheService {
  final CollectionReference tacheCollection =
      FirebaseFirestore.instance.collection('taches');

  // Ajouter une tâche
  Future<void> ajouterTache(Tache tache) async {
    try {
      tache.assignePar = FirebaseAuth.instance.currentUser!.uid;
      await tacheCollection.add(tache.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout de la tâche: $e');
      throw e; // Propager l'erreur pour la gestion à un niveau supérieur
    }
  }

  //Fonction pour ajouter une tache et recupérer l'id de la tâche
  Future<String> ajouterTacheID(Tache tache) async {
    try {
      tache.assignePar = FirebaseAuth.instance.currentUser!.uid;

      // Ajouter la tâche et récupérer la référence du document
      DocumentReference docRef = await tacheCollection.add(tache.toMap());

      // Retourner l'ID du document ajouté
      return docRef.id;
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
            assignePar: doc['assignePar'],
            dateLimite: DateTime.parse(doc['dateLimite']),
            statut: doc['statut'],
            priorite: doc['priorite'],
            commentaires: List<String>.from(doc['commentaires']),
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
        'assignePar': tache.assignePar,
        'dateLimite': tache.dateLimite.toIso8601String(),
        'statut': tache.statut,
        'priorite': tache.priorite,
        'commentaires': tache.commentaires,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la tâche: $e');
      throw e;
    }
  }

  Future<Tache?> tacheParId(String id) async {
    try {
      DocumentSnapshot doc = await tacheCollection.doc(id).get();
      if (doc.exists) {
        // Utilisation de la méthode fromDocument en passant le document et l'ID
        return Tache.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        print('Utilisateur non trouvé pour l\'ID: $id');
        return null; // Retourne null si l'utilisateur n'existe pas
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      throw e; // Propager l'erreur pour la gestion à un niveau supérieur
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
