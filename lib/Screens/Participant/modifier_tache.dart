import 'package:firebase_auth/firebase_auth.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Tache.dart';
import 'package:gwele/Screens/Widgets/user_info_widget.dart';
import 'package:gwele/Services/TacheService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModifierTache extends StatefulWidget {
  final Tache tache; // La tâche à modifier

  const ModifierTache({Key? key, required this.tache}) : super(key: key);

  @override
  _ModifierTacheState createState() => _ModifierTacheState();
}

class _ModifierTacheState extends State<ModifierTache> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _titre;
  late String _description;
  late DateTime _dateLimite;
  String _priorite = 'moyenne';
  String _assigneA = ''; // Id de l'utilisateur assigné
  List<DocumentSnapshot> _participants = []; // Liste des participants

  String _userRole = 'UTILISATEUR'; // Rôle par défaut (sera mis à jour)

  @override
  void initState() {
    super.initState();
    _titre = widget.tache.titre ?? '';
    _description = widget.tache.description ?? '';
    _dateLimite = widget.tache.dateLimite ?? DateTime.now();
    _priorite = widget.tache.priorite ?? 'moyenne';
    _assigneA = widget.tache.assigneA; // Assigné à l'utilisateur sélectionné
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

  // Fonction pour soumettre la modification de la tâche
  void _submitTask() {
    _formKey.currentState!.save();

    Tache tacheModifiee = Tache(
      titre: _titre,
      description: _description,
      dateLimite: _dateLimite,
      statut: widget.tache.statut, // Garder le même statut
      id: widget.tache.id, // Utiliser l'ID de la tâche existante
      assignePar: widget.tache.assignePar, // Garder le même assigné par
      assigneA: _assigneA, // Assigné à l'utilisateur sélectionné
      priorite: _priorite,
      commentaires: widget.tache.commentaires, // Garder les commentaires
    );

    // Appel au service de mise à jour de la tâche
    TacheService().mettreAJourTache(tacheModifiee);

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
        title: const Text("Modifier la tâche"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              const Text(
                "Modifier une tâche",
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
                      initialValue: _titre,
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
                      initialValue: _description,
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
                        value: _assigneA,
                        decoration: const InputDecoration(labelText: 'Assigner à'),
                        items: _participants.map((participant) {
                          return DropdownMenuItem(
                            value: participant.id,
                            child: UserInfoWidget(userId: participant.id, size: 15), // Afficher le nom de l'utilisateur
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
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Modifier'),
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