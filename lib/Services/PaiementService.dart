import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Models/Paiement.dart';
import 'package:gwele/Services/FactureService.dart';

class PaiementService {
  final CollectionReference paiementsCollection =
  FirebaseFirestore.instance.collection('paiements');

  // Ajouter un nouveau paiement
  Future<void> ajouterPaiement(Paiement paiement, Facture facture) async {
    try {
      // Ajouter le paiement avec les informations fournies
      DocumentReference docRef = await paiementsCollection.add(paiement.toMap());

      // Mise à jour de l'objet Paiement avec l'ID généré
      paiement.id = docRef.id;
      PaiementService().mettreAJourPaiement(paiement);
      facture.idPaiements.add(paiement.id);
      await FactureService().mettreAJourFacture(facture);

      print('Paiement ajouté avec succès avec l\'ID: ${paiement.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout du paiement: $e');
      throw e;
    }
  }

  // Récupérer un paiement par son ID
  Future<Paiement?> paiementParId(String id) async {
    try {
      DocumentSnapshot doc = await paiementsCollection.doc(id).get();
      if (doc.exists) {
        return Paiement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        print('Paiement non trouvé pour l\'ID: $id');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du paiement: $e');
      throw e;
    }
  }

  // Récupérer la liste de tous les paiements
  Stream<List<Paiement>> getPaiements() {
    try {
      return paiementsCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Paiement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des paiements: $e');
      rethrow;
    }
  }

  // Mettre à jour un paiement existant
  Future<void> mettreAJourPaiement(Paiement paiement) async {
    try {
      await paiementsCollection.doc(paiement.id).update(paiement.toMap());
      print('Paiement mis à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour du paiement: $e');
      throw e;
    }
  }

  // Supprimer un paiement par ID
  Future<void> supprimerPaiement(String id) async {
    try {
      await paiementsCollection.doc(id).delete();
      print('Paiement supprimé avec succès');
    } catch (e) {
      print('Erreur lors de la suppression du paiement: $e');
      throw e;
    }
  }
}
