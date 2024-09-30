import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Colors.dart';

// Widget pour afficher le bouton de sélection des participants
class AffichageBoutonSelectionParticipant extends StatelessWidget {
  final String title;
  final String buttonText;
  final Function(Map<String, dynamic>) onParticipantSelected;
  final Future<QuerySnapshot> Function() fetchParticipants; // Ajout du paramètre fetchParticipants
  final Function() setState; // Ajout de setState

  AffichageBoutonSelectionParticipant({
    required this.title,
    required this.buttonText,
    required this.onParticipantSelected,
    required this.fetchParticipants, // Ajout de fetchParticipants dans le constructeur
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
                      onParticipantSelected(participantData);
                      setState(); // Appeler setState après la sélection
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
      child: Text(buttonText, style: TextStyle(color: thirdColor)),
    );
  }
}
