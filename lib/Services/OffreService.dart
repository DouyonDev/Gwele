import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gwele/Models/Offre.dart';

class OffreService {
  final CollectionReference offreCollection =
  FirebaseFirestore.instance.collection('offres');

  // Ajouter une offre
  Future<void> ajouterOffre(Offre offre) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      offre.soumisPar = user!.uid;
      // Utiliser la méthode toFirestore de l'instance Offre
      await offreCollection.add(offre.toMap());
      print('Offre ajoutée avec l\'ID: ${offre.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'offre: $e');
      throw e;
    }
  }

  // Récupérer une liste d'offres
  Stream<List<Offre>> listeOffres() {
    try {
      return offreCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          // Utiliser la méthode fromFirestore pour chaque document
          return Offre.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des offres: $e');
      rethrow;
    }
  }

  // Mise à jour d'une offre
  Future<void> mettreAJourOffre(Offre offre) async {
    try {
      // Utiliser la méthode toFirestore pour la mise à jour
      await offreCollection.doc(offre.id).update(offre.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'offre: $e');
      throw e;
    }
  }

  // Suppression d'une offre
  Future<void> supprimerOffre(String id) async {
    try {
      await offreCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'offre: $e');
      throw e;
    }
  }
}
