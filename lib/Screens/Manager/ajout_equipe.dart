import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Equipe.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/affichage_boutons_selection_participant.dart';
import 'package:gwele/Services/BoutonService.dart';
import 'package:gwele/Services/UtilisateurService.dart';


class AjoutEquipe extends StatefulWidget {
  @override
  AjoutEquipeState createState() => AjoutEquipeState();
}

class AjoutEquipeState extends State<AjoutEquipe> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _nomEquipe = '';
  String _leaderId = '';
  String _secondId = '';

  Utilisateur? selectedLeader;
  Utilisateur? selectedSecond;

  // Fonction pour sélectionner le leader
  void onLeaderSelected(String participantID) async {
    try {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(participantID);
      if (utilisateur != null) {
        setState(() {
          selectedLeader = utilisateur;
          _leaderId = participantID;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leader sélectionné: ${selectedLeader?.prenom} ${selectedLeader?.nom}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection du leader: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération du leader')),
      );
    }
  }

// Fonction pour sélectionner l'adjoint
  void onAdjointSelected(String participantID) async {
    try {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(participantID);
      if (utilisateur != null) {
        setState(() {
          selectedSecond = utilisateur;
          _secondId = participantID;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adjoint sélectionné: ${selectedSecond?.prenom} ${selectedSecond?.nom}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'adjoint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération de l\'adjoint')),
      );
    }
  }

  // Fonction pour récupérer la liste des participants depuis Firestore
  Future<QuerySnapshot> fetchParticipants() async {
    return await FirebaseFirestore.instance.collection('utilisateurs').get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor), // Icône retour
          onPressed: () {
            Navigator.pop(context); // Retourner à l'écran précédent
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Image.asset("assets/images/logoGwele.png", height: 150),
              const SizedBox(height: 30),
              const Text(
                "Ajout d'une équipe",
                style: TextStyle(fontSize: 24, color: primaryColor),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'équipe',
                        prefixIcon: Icon(Icons.group),
                      ),
                      style: const TextStyle(fontSize: 16, color: secondaryColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom de l\'équipe ne doit pas être vide';  // Message d'erreur si vide
                        }
                        return null;  // Retourne null si la validation est correcte
                      },
                      onSaved: (value) {
                        _nomEquipe = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Sélection du leader
                    Row(
                      children: [
                        AffichageBoutonSelectionParticipant(
                          title: 'Choisissez le leader du groupe',
                          buttonText: 'Choisir le leader',
                          onParticipantSelected: onLeaderSelected,
                          setState: () => setState(() {}), // Appel à setState dans le parent
                          fetchParticipants: fetchParticipants,
                        ),
                        if (selectedLeader != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: selectedLeader?.imageUrl != null && selectedLeader!.imageUrl.isNotEmpty
                                      ? NetworkImage(selectedLeader!.imageUrl) // Assurez-vous que l'URL n'est pas vide
                                      : const AssetImage('assets/images/boy.png'), // Pas besoin de caster ici
                                ),
                                Text(
                                  '${selectedLeader?.prenom ?? 'Inconnu'} ${selectedLeader?.nom ?? 'Inconnu'}',
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Sélection de l'adjoint
                    Row(
                      children: [
                        AffichageBoutonSelectionParticipant(
                          title: 'Choisissez l\'adjoint du groupe',
                          buttonText: 'Choisir l\'adjoint',
                          onParticipantSelected: onAdjointSelected,
                          setState: () => setState(() {}), // Appel à setState dans le parent
                          fetchParticipants: fetchParticipants,
                        ),
                        if (selectedSecond != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: selectedSecond?.prenom != null && selectedSecond!.nom.isNotEmpty
                                      ? NetworkImage(selectedSecond!.imageUrl) // Assurez-vous que l'URL n'est pas vide
                                      : const AssetImage('assets/images/boy.png'), // Pas besoin de caster ici
                                ),
                                Text(
                                  '${selectedSecond?.prenom ?? 'Inconnu'} ${selectedSecond?.nom ?? 'Inconnu'}',
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Si le formulaire est valide, enregistrer les données
                          _formKey.currentState!.save(); // Sauvegarde des données du formulaire

                          Equipe nouvelleEquipe = Equipe(
                            id: '',
                            nom: _nomEquipe,
                            leaderId: _leaderId,
                            secondId: _secondId,
                            managerId: '',
                            membres: [],
                            dateCreation: DateTime.now(),
                            reunions: [],
                          );
                          print(nouvelleEquipe.leaderId);
                          print(nouvelleEquipe.secondId);
                          BoutonService().boutonAjoutEquipe(_formKey, context, nouvelleEquipe);
                          _formKey.currentState!.reset();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: primaryColor,
                      ),
                      child: const Text("Enregistrer l'équipe", style: TextStyle(color: thirdColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
