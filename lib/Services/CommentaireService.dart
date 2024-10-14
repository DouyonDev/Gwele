import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Models/Commentaire.dart';

class CommentaireService {
  final CollectionReference reunionCollection =
  FirebaseFirestore.instance.collection('reunions');

  // Ajouter un commentaire pour une réunion spécifique
  Future<void> ajouterCommentaire(Commentaire commentaire) async {
    try {
      DocumentReference docRef = await reunionCollection
          .doc(commentaire.reunionId) // Lien vers la réunion
          .collection('commentaires') // Collection de commentaires
          .add(commentaire.toMap());

      // Mise à jour de l'objet Commentaire avec l'ID généré
      commentaire.id = docRef.id;

      print('Commentaire ajouté avec succès avec l\'ID: ${commentaire.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      throw e;
    }
  }

  // Récupérer les commentaires d'une réunion spécifique
  Stream<List<Commentaire>> obtenirCommentaires(String reunionId) {
    try {
      return reunionCollection
          .doc(reunionId)
          .collection('commentaires') // Accéder à la sous-collection des commentaires
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Commentaire.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des commentaires: $e');
      rethrow;
    }
  }

  // Mettre à jour un commentaire existant
  Future<void> mettreAJourCommentaire(Commentaire commentaire) async {
    try {
      await reunionCollection
          .doc(commentaire.reunionId)
          .collection('commentaires')
          .doc(commentaire.id)
          .update(commentaire.toMap());

      print('Commentaire mis à jour avec succès.');
    } catch (e) {
      print('Erreur lors de la mise à jour du commentaire: $e');
      throw e;
    }
  }

  // Supprimer un commentaire
  Future<void> supprimerCommentaire(String reunionId, String commentaireId) async {
    try {
      await reunionCollection
          .doc(reunionId)
          .collection('commentaires')
          .doc(commentaireId)
          .delete();

      print('Commentaire supprimé avec succès.');
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
      throw e;
    }
  }
}
