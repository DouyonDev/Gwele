import 'package:firebase_auth/firebase_auth.dart';
import 'package:gwele/Models/Tache.dart';
import 'package:gwele/Services/TacheService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import '../../Colors.dart';

class AjoutTache extends StatefulWidget {
  @override
  _AjoutTacheState createState() => _AjoutTacheState();
}

class _AjoutTacheState extends State<AjoutTache> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _titre = '';
  String _description = '';
  DateTime _dateLimite = DateTime.now(); // Date initialisée à maintenant
  String _priorite = 'moyenne';
  String _assigneA = ''; // Id de l'utilisateur assigné
  List<DocumentSnapshot> _participants = []; // Liste des participants

  String _userRole = 'UTILISATEUR'; // Rôle par défaut (sera mis à jour)

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Récupérer le rôle de l'utilisateur
  }

  // Fonction pour récupérer le rôle de l'utilisateur depuis Firestore
  Future<void> _fetchUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(currentUser.uid)
          .get();

      setState(() {
        _userRole = userDoc['role']; // Assigner le rôle
      });

      if (_userRole == 'ADMIN' || _userRole == 'MANAGER' || _userRole == 'LEAD') {
        _fetchParticipants(); // Charger les participants seulement si nécessaire
      } else {
        _assigneA = currentUser.uid; // Si l'utilisateur n'est pas ADMIN, MANAGER ou LEAD, il est automatiquement assigné
      }
    }
  }

  // Fonction pour récupérer la liste des participants depuis Firestore
  Future<void> _fetchParticipants() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('utilisateurs').get();
    setState(() {
      _participants = snapshot.docs; // Charger la liste des participants
    });
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

  // Fonction pour soumettre la tâche
  void _submitTask() {
    _formKey.currentState!.save();

    Tache nouvelleTache = Tache(
      titre: _titre,
      description: _description,
      dateLimite: _dateLimite,
      statut: 'En attente',
      id: '',
      assignePar: FirebaseAuth.instance.currentUser?.uid ?? '',
      assigneA: _assigneA, // Assigné à l'utilisateur sélectionné ou lui-même
      priorite: _priorite,
      commentaires: [],
    );

    // Appel au service d'ajout de la tâche
    TacheService().ajouterTache(nouvelleTache);

    _formKey.currentState!.reset();
    Navigator.pop(context); // Retourner à l'écran précédent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logoGwele.png",
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                "Ajout d'une tâche",
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
                        labelText: 'Titre de la tâche',
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

                    // Sélection de la priorité
                    DropdownButtonFormField<String>(
                      value: _priorite,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: const [
                        DropdownMenuItem(value: 'haute', child: Text('Haute')),
                        DropdownMenuItem(value: 'moyenne', child: Text('Moyenne')),
                        DropdownMenuItem(value: 'basse', child: Text('Basse')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _priorite = value;
                          });
                        }
                      },
                      hint: const Text('Sélectionnez une priorité'),
                    ),
                    const SizedBox(height: 20),

                    // Date de la tâche
                    ListTile(
                      title: Text(
                        'Date limite: ${_dateLimite.day}/${_dateLimite.month}/${_dateLimite.year}',
                        style: const TextStyle(color: secondaryColor),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: primaryColor),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),

                    // Afficher le bouton pour assigner à un membre uniquement si le rôle le permet
                    if (_userRole == 'ADMIN' || _userRole == 'MANAGER' || _userRole == 'LEAD')
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Assigner à'),
                        items: _participants.map((participant) {
                          return DropdownMenuItem(
                            value: participant.id,
                            child: Text(''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _assigneA = value;
                            });
                          }
                        },
                        hint: const Text('Sélectionnez un participant'),
                      ),

                    const SizedBox(height: 20),

                    // Bouton soumettre
                    ElevatedButton(
                      onPressed: _submitTask,
                      child: const Text('Ajouter'),
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
