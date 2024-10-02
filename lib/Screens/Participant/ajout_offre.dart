import 'dart:ffi';
import 'dart:io';
import 'package:gwele/Models/Offre.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/OffreService.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/affichage_boutons_selection_participant.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import '../../Colors.dart';
import '../../Models/Reunion.dart';
import '../../Services/BoutonService.dart';

class AjoutOffre extends StatefulWidget {
  @override
  _AjoutOffreState createState() => _AjoutOffreState();
}

class _AjoutOffreState extends State<AjoutOffre> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _titre = '';
  String _description = '';
  DateTime _dateLimite = DateTime.now(); // Date initialisée à maintenant
  List<String> documents = []; // Liste des documents
  String _soumisPar = '';
  List<File> fichiersSelectionnes = []; // Liste des fichiers selectionnes

  // Fonction pour récupérer la liste des participants depuis Firestore
  Future<QuerySnapshot> fetchParticipants() async {
    return await FirebaseFirestore.instance.collection('utilisateurs').get();
  }

  // Sélection de la date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateLimite,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateLimite = picked;
      });
    }
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
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              //const SizedBox(height: 30),
              Image.asset(
                "assets/images/logoGwele.png",
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                "Ajout d'une offre",
                style: TextStyle(
                  fontSize: 24,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    // Titre
                    TextFormField(
                      key: const ValueKey('titre'),
                      decoration: const InputDecoration(
                        labelText: 'Titre de l\'offre',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _titre = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    TextFormField(
                      key: const ValueKey('description'),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date de la réunion
                    ListTile(
                      title: Text(
                        'Date: ${_dateLimite.day}/${_dateLimite.month}/${_dateLimite.year}',
                        style: const TextStyle(color: secondaryColor),
                      ),
                      trailing: const Icon(
                          Icons.calendar_today,
                          color: primaryColor,
                      ),
                      onTap: () => _selectDate(context),
                    ),

                    const SizedBox(height: 20),

                    //Zone pour les documents
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Espace entre le texte et l'icône
                          children: [
                            const Expanded(
                              // Assure que le texte prend tout l'espace disponible à gauche
                              child: Text(
                                "Les documents",
                                style: TextStyle(
                                  color: primaryColor, // Couleur personnalisée
                                  fontSize:
                                      16.0, // Taille de la police personnalisée
                                ),
                              ),
                            ),
                            Align(
                              // Aligner l'icône à droite
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () async {
                                  fichiersSelectionnes = await BoutonService()
                                      .selectionnerEtAfficherFichier(
                                          context, setState, fichiersSelectionnes);
                                },
                                icon: const Icon(Icons.add),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor.withOpacity(
                                      0.6), // Exemple avec 50% d'opacité
                                ),
                                color:
                                    primaryColor, // Couleur de l'icône personnalisée (optionnel)
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Column(
                          children: fichiersSelectionnes.map((file) {
                            // Obtenir le nom du fichier à partir du chemin
                            String fileName = path.basename(file.path); // Extraire le nom du fichier
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file), // Icône pour le fichier
                              title: Text(fileName), // Affiche uniquement le nom du fichier
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline), // Bouton pour supprimer
                                onPressed: () {
                                  // Action pour supprimer un document de la liste
                                  setState(() {
                                    fichiersSelectionnes.remove(file);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),

                      ],
                    ),

                    // Bouton soumettre
                    ElevatedButton(
                      onPressed: () {
                        _formKey.currentState!.save();

                        fichiersSelectionnes.map((file) async {
                          String fileName = path.basename(file.path);
                          String fichierUrl = await FichiersService().uploaderFichierOffre(file, fileName);
                          documents.add(fichierUrl);
                        }).toList();

                        Offre nouvelleOffre = Offre(
                          titre: _titre,
                          description: _description,
                          dateLimite: _dateLimite,
                          documents: documents,
                          statut: 'En attente',
                          id: '',
                          soumisPar: '',
                        );
                        print("les documents");
                        print(nouvelleOffre.documents);
                        //OffreService().ajouterOffre(nouvelleOffre);

                        //_formKey.currentState!.reset();
                      },
                      child: const Text('Ajouter l\'offre'),
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

