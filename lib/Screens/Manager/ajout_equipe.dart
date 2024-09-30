import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Colors.dart';
import '../../Models/Equipe.dart';
import '../../Services/BoutonService.dart';
import '../Widgets/affichage_boutons_selection_participant.dart';

class AjoutEquipe extends StatefulWidget {
  @override
  AjoutEquipeState createState() => AjoutEquipeState();
}

class AjoutEquipeState extends State<AjoutEquipe> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _nomEquipe = '';
  String _leaderId = '';
  String _secondId = '';

  Map<String, dynamic>? selectedLeader;
  Map<String, dynamic>? selectedSecond;

  // Fonction pour récupérer la liste des participants depuis Firestore
  Future<QuerySnapshot> fetchParticipants() async {
    return await FirebaseFirestore.instance.collection('utilisateurs').get();
  }

  // Fonction pour sélectionner le leader
  void onLeaderSelected(Map<String, dynamic> participant) {
    setState(() {
      selectedLeader = participant;
      _leaderId = participant['id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Leader sélectionné: ${participant['nom']}')),
      );
    });
  }

  // Fonction pour sélectionner l'adjoint
  void onAdjointSelected(Map<String, dynamic> participant) {
    setState(() {
      selectedSecond = participant;
      _secondId = participant['id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adjoint sélectionné: ${participant['nom']}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                          fetchParticipants: fetchParticipants,
                          setState: () => setState(() {}), // Appel à setState dans le parent
                        ),
                        if (selectedLeader != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: selectedLeader?['imageUrl'] != null && selectedLeader!['imageUrl'].isNotEmpty
                                      ? NetworkImage(selectedLeader!['imageUrl']) // Assurez-vous que l'URL n'est pas vide
                                      : const AssetImage('assets/images/boy.png'), // Pas besoin de caster ici
                                ),
                                Text(
                                  '${selectedLeader!['prenom'] ?? 'Inconnu'} ${selectedLeader!['nom'] ?? 'Inconnu'}',
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
                          fetchParticipants: fetchParticipants,
                          setState: () => setState(() {}), // Appel à setState dans le parent
                        ),
                        if (selectedSecond != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: selectedSecond?['imageUrl'] != null && selectedSecond!['imageUrl'].isNotEmpty
                                      ? NetworkImage(selectedSecond!['imageUrl']) // Assurez-vous que l'URL n'est pas vide
                                      : const AssetImage('assets/images/boy.png'), // Pas besoin de caster ici
                                ),
                                Text(
                                  '${selectedSecond!['prenom'] ?? 'Inconnu'} ${selectedSecond!['nom'] ?? 'Inconnu'}',
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
                            membres: [],
                            dateCreation: DateTime.now(),
                          );
                          BoutonService().boutonAjoutEquipe(_formKey, context, nouvelleEquipe);
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
