import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/UtilisateurService.dart';

class ListeParticipantsService {

  Future<QuerySnapshot> listeMembresEquipe() async {
    final currentUserId = await AuthService().idUtilisateurConnecte();

    if (currentUserId == null) {
      throw Exception("Aucun utilisateur connecté");
    }

    Utilisateur? currentUserInfo = await UtilisateurService().utilisateurParId(currentUserId);
    if (currentUserInfo == null) {
      throw Exception("L'utilisateur connecté n'existe pas dans la base de données");
    }

    final String role = currentUserInfo.role ?? '';

    if (role == 'MANAGER') {
      return await FirebaseFirestore.instance
          .collection('utilisateurs')
          .where('userMere', isEqualTo: currentUserId)
          .get();
    } else if (role == 'MEMBRE') {
      final QuerySnapshot equipesQuery = await FirebaseFirestore.instance
          .collection('equipes')
          .where('leaderId', isEqualTo: currentUserId)
          .get();

      if (equipesQuery.docs.isEmpty) {
        throw Exception("Aucune équipe trouvée pour ce leader");
      }

      final List<dynamic> membresIds = equipesQuery.docs.first['membres'];
      if (membresIds.isEmpty) {
        throw Exception("L'équipe n'a pas de membres");
      }

      return await FirebaseFirestore.instance
          .collection('utilisateurs')
          .where(FieldPath.documentId, whereIn: membresIds)
          .get();
    } else {
      throw Exception("Rôle non géré : $role");
    }
  }

  Future<QuerySnapshot> listeParticipantsPourReunion(String reunionId) async {
    // Récupérer la réunion pour obtenir les participants
    final reunionDoc = await FirebaseFirestore.instance
        .collection('reunions')
        .doc(reunionId)
        .get();

    if (!reunionDoc.exists) {
      throw Exception("Réunion non trouvée");
    }

    // Récupérer les participants de la réunion
    final List<dynamic> participantsIds = reunionDoc['participants'];

    if (participantsIds.isEmpty) {
      throw Exception("Aucun participant trouvé pour cette réunion");
    }

    // Récupérer les informations des participants
    return await FirebaseFirestore.instance
        .collection('utilisateurs')
        .where(FieldPath.documentId, whereIn: participantsIds)
        .get();
  }

}