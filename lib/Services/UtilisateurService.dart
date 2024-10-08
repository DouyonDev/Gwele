import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Services/AuthService.dart';

import '../Models/Utilisateur.dart';

class UtilisateurService {
  final CollectionReference utilisateurCollection =
      FirebaseFirestore.instance.collection('utilisateurs');

  // Ajouter un utilisateur avec un ID généré automatiquement par Firestore
  Future<void> ajouterUtilisateur(Utilisateur utilisateur) async {
    try {
      // Utilise `doc()` avec l'ID fourni par `utilisateur.id` et la méthode `set()` pour enregistrer les données
      await utilisateurCollection.doc(utilisateur.id).set(utilisateur.toMap());

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

  //
  Future<List<Utilisateur>> recupererMembres(List<String> membresIds) async {
    List<Utilisateur> membres = [];

    for (String id in membresIds) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('utilisateurs').doc(id).get();
      if (doc.exists) {
        // Conversion des données du document en un objet de type Utilisateur
        Utilisateur utilisateur = Utilisateur.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
        membres.add(utilisateur);
      }
    }

    return membres;
  }


  Future<QuerySnapshot> listeParticipantPourReunion() async {
    final currentUserId = await AuthService().idUtilisateurConnecte();

    if (currentUserId == null) {
      throw Exception("Aucun utilisateur connecté");
    }

    // Récupérer les informations de l'utilisateur connecté
    Utilisateur? currentUserInfo = await utilisateurParId(currentUserId);

    if (currentUserInfo == null) {
      throw Exception("L'utilisateur connecté n'existe pas dans la base de données");
    }

    //final userData = userDoc.data();
    final String role = currentUserInfo.role ?? ''; // Le rôle de l'utilisateur (e.g., 'MANAGER', 'LEADER')

    if (role == 'MANAGER') {
      // Si l'utilisateur est un MANAGER, récupérer les utilisateurs qu'il a ajoutés
      return await FirebaseFirestore.instance
          .collection('utilisateurs')
          .where('userMere', isEqualTo: currentUserId)
          .get();
    } else if (role == 'MEMBRE') {
      // Si l'utilisateur est un LEADER, récupérer l'équipe dont il est leader
      final QuerySnapshot equipesQuery = await FirebaseFirestore.instance
          .collection('equipes')
          .where('idLeader', isEqualTo: currentUserId)
          .get();

      if (equipesQuery.docs.isEmpty) {
        throw Exception("Aucune équipe trouvée pour ce leader");
      }

      // Récupérer l'ID des membres de l'équipe
      final List<dynamic> membresIds = equipesQuery.docs.first['membres'];

      // Vérifier que la liste n'est pas vide
      if (membresIds.isEmpty) {
        throw Exception("L'équipe n'a pas de membres");
      }

      // Récupérer les documents des utilisateurs dont l'ID est dans la liste des membres
      return await FirebaseFirestore.instance
          .collection('utilisateurs')
          .where(FieldPath.documentId, whereIn: membresIds)
          .get();
    } else {
      throw Exception("Rôle non géré : $role");
    }
  }



}
