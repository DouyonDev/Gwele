import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/affichage_boutons_selection_participant.dart';
import 'package:gwele/Screens/Widgets/message_modale.dart';
import 'package:gwele/Services/ReunionService.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/UtilsService.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/BoutonService.dart';

class ModifierReunion extends StatefulWidget {
  final Reunion reunion;

  ModifierReunion({required this.reunion});

  @override
  _ModifierReunionState createState() => _ModifierReunionState();
}

class _ModifierReunionState extends State<ModifierReunion> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _titre;
  String? _description;
  DateTime? _dateReunion;
  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;
  String? _lieu;
  List<String> _participants = [];
  List<String> _ordreDuJour = [];
  List<String> documents = [];
  List<File> fichiersSelectionnes = [];

  // Contrôleurs de texte
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titre = widget.reunion.titre;
    _description = widget.reunion.description;
    _dateReunion = widget.reunion.dateReunion;
    _heureDebut = widget.reunion.heureDebut;
    _heureFin = widget.reunion.heureFin;
    _lieu = widget.reunion.lieu;
    _participants = List.from(widget.reunion.participants);
    _ordreDuJour = List.from(widget.reunion.ordreDuJour);
    documents = List.from(widget.reunion.documents);

    // Initialiser les contrôleurs avec les valeurs par défaut
    _titreController.text = _titre!;
    _descriptionController.text = _description!;
    _lieuController.text = _lieu!;
  }

  @override
  void dispose() {
    // Libérer les contrôleurs lorsque l'état est détruit
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
        title: Text('Modifier Réunion ' + '\n ${widget.reunion.titre}'),
        centerTitle: true,
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
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                buildTextField(
                  'Titre de la réunion',
                  _titreController,
                      (value) {
                    _titre = value!;
                  },
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le titre de la réunion ne doit pas être vide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                buildTextField(
                  'Description',
                  _descriptionController,
                      (value) {
                    _description = value!;
                  },
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez donner une description à la réunion';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                buildTextField(
                  'Lieu',
                  _lieuController,
                      (value) {
                    _lieu = value!;
                  },
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez donner le lieu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                buildDateTimePicker('Date', () {
                  UtilsService().selectDate(context, _dateReunion!, (DateTime pickedDate) {
                    setState(() {
                      _dateReunion = pickedDate;
                    });
                  });
                }, 'Date: ${UtilsService().formatDate(_dateReunion!.toLocal())}', Icons.calendar_today),
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
                          return const AlertDialog(
                            title: Text("Erreur"),
                            content: Text("Veuillez choisir l'heure de début et de fin."),
                          );
                        },
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      Reunion updatedReunion = Reunion(
                        id: widget.reunion.id,
                        titre: _titre!,
                        description: _description!,
                        statut: "En attente",
                        dateReunion: _dateReunion!,
                        heureDebut: _heureDebut!,
                        heureFin: _heureFin!,
                        participants: _participants,
                        lieu: _lieu!,
                        isCompleted: false,
                        lead: '',
                        rapporteur: '',
                        ordreDuJour: _ordreDuJour,
                        tachesAssignees: [],
                        documents: documents,
                      );

                      // Mettre à jour les fichiers
                      for (var file in fichiersSelectionnes) {
                        String fileName = path.basename(file.path);
                        String fichierUrl = await FichiersService().uploaderFichierReunion(file, fileName);
                        documents.add(fichierUrl);
                      }

                      // Sauvegarder la réunion mise à jour dans Firestore
                      ReunionService().mettreAJourReunion(widget.reunion);

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return MessageModale(
                            title: widget.reunion.titre,
                            content: "Mis à jour réussie.",
                          );
                        },
                      );

                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text(
                    'Mettre à jour la réunion',
                    style: TextStyle(color: thirdColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextField(String label, TextEditingController controller, Function(String?) onSaved, String? Function(String?) validator, {int maxLines = 1, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller, // Utiliser le contrôleur
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xffA6A6A6)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      style: const TextStyle(color: secondaryColor, fontSize: 16),
      validator: validator,
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
            AffichageBoutonSelectionParticipant(
              title: "Sélectionner un Participant",
              buttonText: "Ajouter un participant",
              onParticipantSelected: (participantID) {
                setState(() {
                  _participants.add(participantID);
                });
              },
              setState: () {
                setState(() {});
              },
              fetchParticipants: () async {
                // Récupérer les participants depuis Firestore
                return await FirebaseFirestore.instance.collection('utilisateurs').get();
              },
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
