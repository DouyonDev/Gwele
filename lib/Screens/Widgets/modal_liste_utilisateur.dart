import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Colors.dart';

class ModalListeUtilisateur extends StatelessWidget {
  final String titleLeader; // Titre de la modale pour leader
  final String titleAdjoint; // Titre de la modale pour adjoint
  final String textBoutonLeader; // Texte du bouton pour leader
  final String textBoutonAdjoint; // Texte du bouton pour adjoint
  final Future<QuerySnapshot> Function() fetchParticipants; // Fonction pour récupérer les participants
  final Function(Map<String, dynamic>) onLeaderSelected; // Action lors de la sélection du leader
  final Function(Map<String, dynamic>) onAdjointSelected; // Action lors de la sélection de l'adjoint

  ModalListeUtilisateur({
    required this.titleLeader,
    required this.titleAdjoint,
    required this.fetchParticipants,
    required this.onLeaderSelected,
    required this.onAdjointSelected,
    required this.textBoutonLeader,
    required this.textBoutonAdjoint,
  });

  // Fonction pour afficher la page modale de sélection
  Future<void> _showParticipantModal(
      BuildContext context, String title, Function(Map<String, dynamic>) onSelected) async {
    // Récupérer les données des participants
    QuerySnapshot participantsSnapshot = await fetchParticipants();

    // Afficher la page modale
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.blueGrey,
          ),
          body: ListView.builder(
            itemCount: participantsSnapshot.docs.length,
            itemBuilder: (BuildContext context, int index) {
              // Obtenir un participant
              var participantData = participantsSnapshot.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.person, color: Colors.blueGrey),
                title: Text(
                  '${participantData['prenom'] ?? 'Inconnu'} ${participantData['nom'] ?? 'Inconnu'}',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                subtitle: Text(participantData['email'] ?? 'Email non disponible'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey),
                onTap: () {
                  // Lorsqu'un participant est sélectionné, exécuter la fonction
                  onSelected(participantData);
                  Navigator.pop(context); // Fermer la modale après sélection
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton pour sélectionner le leader
        ElevatedButton(
          onPressed: () {
            _showParticipantModal(context, titleLeader, (participantData) {
              // Lorsqu'un leader est sélectionné
              onLeaderSelected(participantData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Leader sélectionné: ${participantData['nom']} ${participantData['prenom']}'),
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: primaryColor,
          ),
          child: Text(
            textBoutonLeader,
            style: const TextStyle(
              color: thirdColor,
            ),
          ),
        ),

        // Bouton pour sélectionner l'adjoint
        ElevatedButton(
          onPressed: () {
            _showParticipantModal(context, titleAdjoint, (participantData) {
              // Lorsqu'un adjoint est sélectionné
              onAdjointSelected(participantData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Adjoint sélectionné: ${participantData['nom']} ${participantData['prenom']}'),
                ),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: primaryColor,
          ),
          child: Text(
            textBoutonAdjoint,
            style: const TextStyle(
              color: thirdColor,
            ),
          ),
        ),
      ],
    );
  }
}
