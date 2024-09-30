import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Offre.dart';

class OffreService {
  final CollectionReference offreCollection =
      FirebaseFirestore.instance.collection('offres');

  // Ajouter une offre
  Future<void> ajouterOffre(Offre offre) async {
    try {
      await offreCollection.doc(offre.id).set({
        'titre': offre.titre,
        'description': offre.description,
        'dateLimite': offre.dateLimite.toIso8601String(),
        'statut': offre.statut,
        'documents': offre.documents,
        'soumisPar': offre.soumisPar,
        'isExpired': offre.isExpired,
      });
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
          return Offre(
            id: doc.id,
            titre: doc['titre'],
            description: doc['description'],
            dateLimite: DateTime.parse(doc['dateLimite']),
            statut: doc['statut'],
            documents: List<String>.from(doc['documents']),
            soumisPar: doc['soumisPar'],
            isExpired: doc['isExpired'],
          );
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
      await offreCollection.doc(offre.id).update({
        'titre': offre.titre,
        'description': offre.description,
        'dateLimite': offre.dateLimite.toIso8601String(),
        'statut': offre.statut,
        'documents': offre.documents,
        'soumisPar': offre.soumisPar,
        'isExpired': offre.isExpired,
      });
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
