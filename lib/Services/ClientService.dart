import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Client.dart';

class ClientService {
  final CollectionReference clientCollection =
  FirebaseFirestore.instance.collection('clients');

  // Ajouter un nouveau client
  Future<void> ajouterClient(Client client) async {
    try {
      DocumentReference docRef = await clientCollection.add(client.toMap());
      client.id = docRef.id; // Mise à jour de l'objet Client avec l'ID généré
      print('Client ajouté avec succès avec l\'ID: ${client.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout du client: $e');
      throw e;
    }
  }

  // Récupérer un client par son ID
  Future<Client?> getClientById(String id) async {
    try {
      DocumentSnapshot doc = await clientCollection.doc(id).get();
      if (doc.exists) {
        return Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        print('Client non trouvé pour l\'ID: $id');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du client: $e');
      throw e;
    }
  }

  // Récupérer tous les clients
  Stream<List<Client>> getClients() {
    try {
      return clientCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Client.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des clients: $e');
      rethrow;
    }
  }

  // Mettre à jour un client
  Future<void> mettreAJourClient(Client client) async {
    try {
      await clientCollection.doc(client.id).update(client.toMap());
      print('Client mis à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour du client: $e');
      throw e;
    }
  }

  // Supprimer un client par ID
  Future<void> supprimerClient(String id) async {
    try {
      await clientCollection.doc(id).delete();
      print('Client supprimé avec succès');
    } catch (e) {
      print('Erreur lors de la suppression du client: $e');
      throw e;
    }
  }
}
