import 'dart:io';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Screens/Widgets/message_modale.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/BoutonService.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/UtilsService.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/affichage_boutons_selection_participant.dart';
import 'package:gwele/Services/UtilisateurService.dart';

class AjoutReunion extends StatefulWidget {
  @override
  _AjoutReunionState createState() => _AjoutReunionState();
}

class _AjoutReunionState extends State<AjoutReunion> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _description = '';
  DateTime _dateReunion = DateTime.now();
  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;
  String _lieu = '';
  List<String> _participants = [];
  List<String> _ordreDuJour = [];
  List<String> _tachesAssignees = [];
  List<String> documents = [];
  List<File> fichiersSelectionnes = [];

  Future<QuerySnapshot> listeParticipantPourReunion() async {
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

  void onParticipantSelected(String participantID) async {
    try {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(participantID);
      if (utilisateur != null) {
        setState(() {
          _participants.add(participantID);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membre sélectionné: ${utilisateur.prenom} ${utilisateur.nom}')),
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
                "Ajout d'une réunion",
                style: TextStyle(fontSize: 24, color: primaryColor),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    buildTextField(
                      'Titre de la réunion',
                          (value) {
                        _titre = value!;
                      },
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le titre de la réunion ne doit pas être vide';
                        }
                        return null; // La validation est réussie
                      },
                    ),


                    const SizedBox(height: 20),

                    buildTextField(
                      'Description',
                          (value) {
                        _description = value!;
                      },
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez donner une description à la réunion';
                        }
                        return null; // La validation est réussie
                      },
                      maxLines: 3, // Autorise plusieurs lignes pour la description
                    ),

                    const SizedBox(height: 20),

                    buildTextField(
                      'Lieu',
                          (value) {
                        _lieu = value!;
                      },
                          (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez donner le lieu';
                        }
                        return null; // La validation est réussie
                      },
                      prefixIcon: Icons.location_on, // Icône pour le champ de lieu
                    ),

                    const SizedBox(height: 20),

                    buildDateTimePicker('Date', () {
                      UtilsService().selectDate(context, _dateReunion, (DateTime pickedDate) {
                        setState(() {
                          _dateReunion = pickedDate;
                        });
                      });
                    }, 'Date: ${UtilsService().formatDate(_dateReunion.toLocal())}', Icons.calendar_today),

                    const SizedBox(height: 20),

                    buildTimePicker('Heure de début', () {
                      UtilsService().selectTime(context, true, (TimeOfDay picked) {
                        setState(() {
                          _heureDebut = picked;
                        });
                      });
                    }, _heureDebut),

                    const SizedBox(height: 20),

                    buildTimePicker('Heure de fin', () {
                      UtilsService().selectTime(context, true, (TimeOfDay picked) {
                        setState(() {
                          _heureFin = picked;
                        });
                      });
                    }, _heureFin),

                    const SizedBox(height: 20),

                    buildParticipantsSection(),

                    const SizedBox(height: 20),

                    buildDocumentsSection(),

                    const SizedBox(height: 20),

                    buildOrdreDuJourSection(),

                    ElevatedButton(
                      onPressed: () async {
                        if (_heureDebut == null || _heureFin == null) {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MessageModale(
                                  title: "Erreur",
                                  content: "Veuillez choisir l'heure de début et de fin."
                              );
                            },
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          Reunion nouvelleReunion = Reunion(
                            id: '',
                            titre: _titre,
                            description: _description,
                            statut: "En attente",
                            dateReunion: _dateReunion,
                            heureDebut: _heureDebut!,
                            heureFin: _heureFin!,
                            participants: _participants,
                            lieu: _lieu,
                            isCompleted: false,
                            lead: '',
                            rapporteur: '',
                            ordreDuJour: _ordreDuJour,
                            tachesAssignees: _tachesAssignees,
                            documents: documents,
                          );

                          // Uploader les fichiers
                          for (var file in fichiersSelectionnes) {
                            String fileName = path.basename(file.path);
                            String fichierUrl = await FichiersService().uploaderFichierReunion(file, fileName);
                            documents.add(fichierUrl);
                          }

                          BoutonService().btnAjouterReunion(_formKey, context, nouvelleReunion);
                          _formKey.currentState!.reset();
                          setState(() {
                            _heureDebut = null;
                            _heureFin = null;
                            documents = [];
                            fichiersSelectionnes = [];
                            _participants = [];
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      child: const Text(
                        'Programmer la réunion',
                        style: TextStyle(color: thirdColor),
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

  TextFormField buildTextField(
      String label,
      Function(String?) onSaved,
      String? Function(String?) validator, // Gardez ce type pour la validation
          {int maxLines = 1, IconData? prefixIcon}
      ) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffA6A6A6)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      style: const TextStyle(color: secondaryColor, fontSize: 16),
      validator: validator, // Passez la fonction de validation ici
      maxLines: maxLines,
      onSaved: onSaved,
    );
  }


  ListTile buildDateTimePicker(String title, VoidCallback onTap, String subtitle, IconData icon) {
    return ListTile(
      title: Text(subtitle, style: const TextStyle(color: secondaryColor)),
      trailing: Icon(icon, color: primaryColor),
      onTap: onTap,
    );
  }

  ListTile buildTimePicker(String title, VoidCallback onTap, TimeOfDay? time) {
    return ListTile(
      title: Text(
        time == null ? 'Sélectionner $title' : '$title: ${time.format(context)}',
        style: const TextStyle(color: secondaryColor),
      ),
      trailing: const Icon(Icons.access_time, color: primaryColor),
      onTap: onTap,
    );
  }

  Column buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text("Participants", style: TextStyle(color: primaryColor, fontSize: 16.0)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AffichageBoutonSelectionParticipant(
                title: 'Ajouter un participant',
                buttonText: 'Ajouter',
                onParticipantSelected: onParticipantSelected,
                setState: () => setState(() {}),
                fetchParticipants: listeParticipantPourReunion,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: _participants.map((participantID) {
            return FutureBuilder<Utilisateur?>(
              future: UtilisateurService().utilisateurParId(participantID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Chargement...'),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    leading: Icon(Icons.error),
                    title: Text('Erreur lors du chargement du participant'),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Participant inconnu'),
                  );
                } else {
                  Utilisateur? participant = snapshot.data;
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: participant?.imageUrl != null && participant!.imageUrl.isNotEmpty
                          ? NetworkImage(participant.imageUrl)
                          : const AssetImage('assets/images/boy.png') as ImageProvider,
                    ),
                    title: Text('${participant?.prenom ?? 'Inconnu'} ${participant?.nom ?? 'Inconnu'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
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
        ),
      ],
    );
  }

  Column buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text("Les documents", style: TextStyle(color: primaryColor, fontSize: 16.0)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () async {
                  fichiersSelectionnes = await BoutonService()
                      .selectionnerEtAfficherFichier(context, setState, fichiersSelectionnes);
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: fichiersSelectionnes.map((file) {
            String fileName = path.basename(file.path);
            return ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(fileName),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    fichiersSelectionnes.remove(file);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Column buildOrdreDuJourSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Les ordres du jour",
                style: TextStyle(color: primaryColor, fontSize: 16.0),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  BoutonService().boutonAjouterOrdreDuJour(context, setState, _ordreDuJour);
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Affichage des ordres du jour
        _ordreDuJour.isNotEmpty
            ? ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ordreDuJour.length,
          itemBuilder: (context, index) {
            String ordreDuJour = _ordreDuJour[index];
            return ListTile(
              title: Text(ordreDuJour),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    _ordreDuJour.removeAt(index);
                  });
                },
              ),
            );
          },
        )
            : const Text(
          'Aucun ordre du jour ajouté.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

}