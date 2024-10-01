import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';

import '../../Colors.dart';

// Widget pour afficher le bouton de sélection des participants
class AffichageBoutonSelectionParticipant extends StatelessWidget {
  String title;
  String buttonText;
  Function(String) onParticipantSelected;
  Function() setState; // Ajout de setState

  // Fonction pour récupérer la liste des participants depuis Firestore
  Future<QuerySnapshot> fetchParticipants() async {
    return await FirebaseFirestore.instance.collection('utilisateurs').get();
  }

  AffichageBoutonSelectionParticipant({
    required this.title,
    required this.buttonText,
    required this.onParticipantSelected,
    required this.setState, // Ajout de setState dans le constructeur
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        QuerySnapshot participantsSnapshot = await fetchParticipants();  // Utilisation de fetchParticipants
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
                  // Récupérer les données du participant et l'ID du document
                  var participantData = participantsSnapshot.docs[index].data() as Map<String, dynamic>;
                  var participantId = participantsSnapshot.docs[index].id; // Récupérer l'ID du participant

                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.blueGrey),
                    title: Text(
                      '${participantData['prenom'] ?? 'Inconnu'} ${participantData['nom'] ?? 'Inconnu'}',
                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                    subtitle: Text(participantData['email'] ?? 'Email non disponible'),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey),
                    onTap: () {
                      setState();
                      onParticipantSelected(participantId); // Passer l'ID du participant
                      Navigator.pop(context); // Fermer la modale après sélection
                    },
                  );
                },

              ),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: primaryColor,
      ),
      child: Text(buttonText, style: const TextStyle(color: thirdColor)),
    );
  }
}
