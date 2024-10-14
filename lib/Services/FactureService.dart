import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Models/Client.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Services/ClientService.dart';

class FactureService {
  final CollectionReference facturesCollection =
  FirebaseFirestore.instance.collection('factures');

  // Ajouter une nouvelle facture avec un numéro saisi par l'utilisateur
  Future<void> ajouterFacture(Facture facture, Client client ) async {
    try {
      // Ajouter la facture avec les informations fournies par l'utilisateur
      DocumentReference docRef = await facturesCollection.add(facture.toMap());

      // Mise à jour de l'objet Facture avec l'ID généré
      facture.id = docRef.id;
      client.idFactures.add(facture.id);
      await ClientService().mettreAJourClient(client);

      print('Facture ajoutée avec succès avec l\'ID: ${facture.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout de la facture: $e');
      throw e;
    }
  }

  // Récupérer une facture par son ID
  Future<Facture?> factureParId(String id) async {
    try {
      DocumentSnapshot doc = await facturesCollection.doc(id).get();
      if (doc.exists) {
        return Facture.fromMap(doc.data() as Map<String, dynamic>, doc.id); // Utilise la méthode fromMap
      } else {
        print('Facture non trouvée pour l\'ID: $id');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de la facture: $e');
      throw e;
    }
  }

  // Récupérer la liste de toutes les factures
  Stream<List<Facture>> getFactures() {
    try {
      return facturesCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Facture.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des factures: $e');
      rethrow;
    }
  }

  // Mettre à jour une facture existante
  Future<void> mettreAJourFacture(Facture facture) async {
    try {
      await facturesCollection.doc(facture.id).update(facture.toMap());
      print('Facture mise à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour de la facture: $e');
      throw e;
    }
  }

  // Supprimer une facture par ID
  Future<void> supprimerFacture(String id) async {
    try {
      await facturesCollection.doc(id).delete();
      print('Facture supprimée avec succès');
    } catch (e) {
      print('Erreur lors de la suppression de la facture: $e');
      throw e;
    }
  }
}
