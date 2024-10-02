import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Utilisateur.dart';

class UtilisateurService {
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('utilisateurs');

  // Ajouter un utilisateur avec un ID généré automatiquement par Firestore
  Future<void> ajouterUtilisateur(Utilisateur utilisateur) async {
    try {
      // Utilisation de la méthode `add()` pour générer automatiquement l'ID
      DocumentReference docRef = await utilisateurCollection.add(utilisateur.toMap());

      // Récupérer l'ID généré automatiquement et mettre à jour l'objet utilisateur
      utilisateur.id = docRef.id;

      print('Utilisateur ajouté avec l\'ID: ${utilisateur.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur: $e');
      throw e; // Propager l'erreur pour la gestion à un niveau supérieur
    }
  }


  // Récupérer une liste d'utilisateurs
  Stream<List<Utilisateur>> listeUtilisateurs() {
    try {
      return utilisateurCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Utilisateur(
            id: doc.id,
            nom: doc['nom'],
            prenom: doc['prenom'],
            role: doc['role'],
            email: doc['email'],
            imageUrl: doc['imageUrl'],
            userMere: doc['userMere'],
            notificationToken: doc['notificationToken'],
            tachesAssignees: List<String>.from(doc['tachesAssignees']),
            reunions: List<String>.from(doc['reunions']),
          );
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      rethrow; // Propager l'erreur
    }
  }

  // Mise à jour d'un utilisateur
  Future<void> mettreAJourUtilisateur(Utilisateur utilisateur) async {
    try {
      await utilisateurCollection.doc(utilisateur.id).update({
        'nom': utilisateur.nom,
        'prenom': utilisateur.prenom,
        'role': utilisateur.role,
        'email': utilisateur.email,
        'tachesAssignees': utilisateur.tachesAssignees,
        'reunions': utilisateur.reunions,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur: $e');
      throw e;
    }
  }

  // Suppression d'un utilisateur
  Future<void> supprimerUtilisateur(String id) async {
    try {
      await utilisateurCollection.doc(id).delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
      throw e;
    }
  }

  // Récupérer un utilisateur par son ID
  Future<Utilisateur?> utilisateurParId(String id) async {
    try {
      DocumentSnapshot doc = await utilisateurCollection.doc(id).get();
      if (doc.exists) {
        // Utilisation de la méthode fromDocument en passant le document et l'ID
        return Utilisateur.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        print('Utilisateur non trouvé pour l\'ID: $id');
        return null; // Retourne null si l'utilisateur n'existe pas
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      throw e; // Propager l'erreur pour la gestion à un niveau supérieur
    }
  }


}
