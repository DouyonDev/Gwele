import 'dart:io';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/UtilsService.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/affichage_boutons_selection_participant.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import '../../Colors.dart';
import '../../Models/Reunion.dart';
import '../../Services/AuthService.dart';
import '../../Services/BoutonService.dart';

class AjoutReunion extends StatefulWidget {
  @override
  _AjoutReunionState createState() => _AjoutReunionState();
}

class _AjoutReunionState extends State<AjoutReunion> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _titre = '';
  String _description = '';
  DateTime _dateReunion = DateTime.now(); // Date initialisée à maintenant
  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;
  String _lieu = '';
  List<String> _participants = [];
  List<String> _ordreDuJour = [];
  List<String> _tachesAssignees = [];
  bool _isCompleted = false;
  String _lead = '';
  List<String> documents = []; // Liste des documents
  List<File> fichiersSelectionnes = []; // Liste des fichiers selectionnes
  List<File> ordreDuJourAjoute = []; // Liste des fichiers selectionnes
  List<File> ordreDuJour = []; // Liste des fichiers selectionnes

  // Fonction pour récupérer la liste des participants depuis Firestore
  Future<QuerySnapshot> listeParticipantPourReunion() async {
    final currentUserId = await AuthService().idUtilisateurConnecte();

    if (currentUserId == null) {
      throw Exception("Aucun utilisateur connecté");
    }

    // Récupérer les informations de l'utilisateur connecté
    Utilisateur? currentUserInfo = await UtilisateurService().utilisateurParId(currentUserId);

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

  // Fonction pour ajouter un membre à la liste des participants
  void onParticipantSelected(String participantID) async {
    try {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(participantID);
      if (utilisateur != null) {
        setState(() {
          _participants.add(participantID);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('membre sélectionné: ${utilisateur.prenom} ${utilisateur.nom}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection du membre: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération du membre')),
      );
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
                "Ajout d'une réunion",
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
                        labelText: 'Titre de la réunion',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le titre de la reunion ne doit pas être vide';  // Message d'erreur si vide
                        }
                        return null;  // Retourne null si la validation est correcte
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez donnez une description a la reunion';  // Message d'erreur si vide
                        }
                        return null;  // Retourne null si la validation est correcte
                      },
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Lieu
                    TextFormField(
                      key: const ValueKey('lieu'),
                      decoration: const InputDecoration(
                        labelText: 'Lieu',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez donnée le lieu';  // Message d'erreur si vide
                        }
                        return null;  // Retourne null si la validation est correcte
                      },
                      onSaved: (value) {
                        _lieu = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date de la réunion
                    ListTile(
                      title: Text(
                        'Date: ${UtilsService().formatDate(_dateReunion.toLocal())}',
                        style: const TextStyle(color: secondaryColor),
                      ),
                      trailing: const Icon(
                          Icons.calendar_today,
                          color: primaryColor,
                      ),
                      onTap: () {
                        // Appel à la fonction selectDate du fichier DateService
                        UtilsService().selectDate(context, _dateReunion, (DateTime pickedDate) {
                          setState(() {
                            _dateReunion = pickedDate;  // Met à jour la date sélectionnée
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Heure de début
                    ListTile(
                      title: Text(
                        _heureDebut == null
                            ? 'Sélectionner l\'heure de début'
                            : 'Heure de début: ${_heureDebut!.format(context)}',
                        style: const TextStyle(color: secondaryColor),
                      ),
                      trailing: const Icon(
                          Icons.access_time,
                          color: primaryColor,
                      ),
                      onTap: () {
                        UtilsService().selectTime(context, true, (TimeOfDay picked) {
                          setState(() {
                            _heureDebut = picked;
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Heure de fin
                    ListTile(
                      title: Text(
                        _heureFin == null
                            ? 'Sélectionner l\'heure de fin'
                            : 'Heure de fin: ${_heureFin!.format(context)}',
                        style: const TextStyle(color: secondaryColor),
                      ),
                      trailing: const Icon(
                          Icons.access_time,
                          color: primaryColor,
                      ),
                      onTap: () {
                        UtilsService().selectTime(context, true, (TimeOfDay picked) {
                          setState(() {
                            _heureFin = picked;
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Disposition pour les participants (similaire aux documents)
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
                                "Participants",
                                style: TextStyle(
                                  color: primaryColor, // Couleur personnalisée
                                  fontSize:
                                      16.0, // Taille de la police personnalisée
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AffichageBoutonSelectionParticipant(
                                title: 'Choisissez l\'adjoint du groupe',
                                buttonText: 'Ajouter',
                                onParticipantSelected: onParticipantSelected,
                                setState: () => setState(() {}), // Appel à setState dans le parent
                                fetchParticipants: listeParticipantPourReunion,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        // Liste des participants sélectionnés
                        Column(
                          children: _participants.map((participantID) {
                            // Utiliser FutureBuilder pour gérer les données asynchrones
                            return FutureBuilder<Utilisateur?>(
                              future: UtilisateurService().utilisateurParId(participantID),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // Afficher un indicateur de chargement pendant que les données se chargent
                                  return const ListTile(
                                    leading: CircularProgressIndicator(),
                                    title: Text('Chargement...'),
                                  );
                                } else if (snapshot.hasError) {
                                  // En cas d'erreur
                                  return const ListTile(
                                    leading: Icon(Icons.error),
                                    title: Text('Erreur lors du chargement du participant'),
                                  );
                                } else if (!snapshot.hasData || snapshot.data == null) {
                                  // Si aucune donnée n'est disponible
                                  return const ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text('Participant inconnu'),
                                  );
                                } else {
                                  // Si les données sont récupérées avec succès
                                  Utilisateur? participant = snapshot.data;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: participant?.imageUrl != null && participant!.imageUrl.isNotEmpty
                                          ? NetworkImage(participant.imageUrl)
                                          : const AssetImage('assets/images/boy.png') as ImageProvider,
                                    ), // Icône avant le nom du participant
                                    title: Text('${participant?.prenom ?? 'Inconnu'} ${participant?.nom ?? 'Inconnu'}'), // Nom du participant
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline), // Bouton pour supprimer
                                      onPressed: () {
                                        // Action pour supprimer un participant de la liste
                                        setState(() {
                                          _participants.remove(participantID);
                                        });
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        )

                      ],
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

                    //Zone pour les ordres du jour
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
                                "Les ordres du jour",
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
                                onPressed: () => BoutonService().boutonAjouterOrdreDuJour(context),
                                icon: const Icon(Icons.add),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor.withOpacity(
                                      0.6), // Exemple avec 50% d'opacité
                                ),
                                color: primaryColor,
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

                        fichiersSelectionnes.map((file) async {
                          String fileName = path.basename(file.path);
                          String fichierUrl = await FichiersService().uploaderFichierReunion(file, fileName);
                          documents.add(fichierUrl);
                        }).toList();

                        // Créer un objet Réunion
                        Reunion nouvelleReunion = Reunion(
                          id: '', // L'ID sera généré automatiquement par Firestore
                          titre: _titre,
                          description: _description,
                          statut: "En attente",
                          dateReunion: _dateReunion,
                          heureDebut: _heureDebut!,
                          heureFin: _heureFin!,
                          participants: _participants,
                          lieu: _lieu,
                          isCompleted: _isCompleted,
                          lead: _lead,
                          ordreDuJour: _ordreDuJour,
                          tachesAssignees: _tachesAssignees,
                          documents: documents, // Ajout des documents
                        );
                        //print(nouvelleReunion.titre);
                        BoutonService().btnAjouterReunion(
                            _formKey,
                            context,
                            nouvelleReunion
                        );
                        //_formKey.currentState!.reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                    ),
                      child: const Text(
                          'Programmer la réunion',
                        style: TextStyle(
                          color: thirdColor,
                        ),
                      ),
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

