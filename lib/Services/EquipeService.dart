import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Equipe.dart';

class EquipeService {
  final CollectionReference equipeCollection =
  FirebaseFirestore.instance.collection('equipes');

  // Ajouter une nouvelle équipe avec un ID généré automatiquement par Firestore
  Future<void> ajouterEquipe(Equipe equipe) async {
    try {
      // Créer un document avec un ID automatique
      DocumentReference docRef = await equipeCollection.add(equipe.toMap());

      // Mise à jour de l'objet Equipe avec l'ID généré
      equipe.id = docRef.id;

      print('Équipe ajoutée avec succès avec l\'ID: ${equipe.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'équipe: $e');
      throw e;
    }
  }

  // Récupérer une équipe par son ID
  Future<Equipe?> getEquipeById(String id) async {
    try {
      DocumentSnapshot doc = await equipeCollection.doc(id).get();
      if (doc.exists) {
        return Equipe.fromDocument(doc.data() as Map<String, dynamic>, doc.id); // Utilise la méthode fromDocument
      } else {
        print('Équipe non trouvée pour l\'ID: $id');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'équipe: $e');
      throw e;
    }
  }

  // Récupérer la liste de toutes les équipes
  Stream<List<Equipe>> getEquipes() {
    try {
      return equipeCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Equipe.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des équipes: $e');
      rethrow;
    }
  }

  // Mettre à jour une équipe existante
  Future<void> mettreAJourEquipe(Equipe equipe) async {
    try {
      await equipeCollection.doc(equipe.id).update(equipe.toMap());
      print('Équipe mise à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'équipe: $e');
      throw e;
    }
  }

  // Supprimer une équipe par ID
  Future<void> supprimerEquipe(String id) async {
    try {
      await equipeCollection.doc(id).delete();
      print('Équipe supprimée avec succès');
    } catch (e) {
      print('Erreur lors de la suppression de l\'équipe: $e');
      throw e;
    }
  }
}
