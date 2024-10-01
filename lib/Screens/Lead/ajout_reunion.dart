import 'package:flutter/material.dart';
import '../../Colors.dart';
import '../../Models/Reunion.dart';
import '../../Services/BoutonService.dart';
import '../../Services/FichiersService.dart';

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
  List<String> _decisions = [];
  List<String> _tachesAssignees = [];
  bool _isCompleted = false;
  String _lead = '';
  List<String> documents = []; // Liste des documents

  List<String> allParticipants = [
    'Alice',
    'Bob',
    'Charlie',
    'Diana'
  ]; // Exemple

  // Fonction pour sélectionner des participants
  Future<void> afficherListeParticipants(BuildContext context) async {
    List<String> selectedParticipants = [
      ..._participants
    ]; // Copie de la liste actuelle

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sélectionner les participants"),
          content: SingleChildScrollView(
            child: Column(
              children: allParticipants.map((participant) {
                return CheckboxListTile(
                  title: Text(participant),
                  value: selectedParticipants.contains(participant),
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        selectedParticipants.add(participant);
                      } else {
                        selectedParticipants.remove(participant);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Valider'),
              onPressed: () {
                setState(() {
                  _participants = selectedParticipants;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final FichiersService fichiersService = FichiersService();
  // Sélection de la date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateReunion,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateReunion = picked;
      });
    }
  }

  // Sélection de l'heure
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _heureDebut = picked;
        } else {
          _heureFin = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
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
                      onSaved: (value) {
                        _lieu = value!;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date de la réunion
                    ListTile(
                      title: Text(
                        'Date: ${_dateReunion.toLocal()}',
                        style: const TextStyle(color: secondaryColor),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
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
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context, true),
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
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context, false),
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
                              child: IconButton(
                                onPressed: () =>
                                    afficherListeParticipants(context),
                                icon: const Icon(Icons.add),
                                color: primaryColor,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor.withOpacity(
                                      0.6), // Exemple avec 50% d'opacité
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        // Liste des participants sélectionnés
                        Column(
                          children: _participants.map((participant) {
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(participant),
                            );
                          }).toList(),
                        ),
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
                                onPressed: () {
                                  this.documents = BoutonService()
                                      .selectionnerEtUploaderFichier(
                                          context, documents) as List<String>;
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
                        // Liste des documents uploadés
                        Column(
                          children: documents.map((docName) {
                            // Découper le nom du fichier à partir du tiret
                            String shortenedName = docName.split(':').first;

                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(
                                shortenedName, // Afficher la partie après le tiret
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    // Bouton soumettre
                    ElevatedButton(
                      onPressed: () {
                        // Créer un objet Réunion
                        Reunion nouvelleReunion = Reunion(
                          id: '', // L'ID sera généré automatiquement par Firestore
                          titre: _titre,
                          description: _description,
                          dateReunion: _dateReunion,
                          heureDebut: _heureDebut!,
                          heureFin: _heureFin!,
                          participants: _participants,
                          lieu: _lieu,
                          isCompleted: _isCompleted,
                          lead: _lead,
                          decisions: _decisions,
                          tachesAssignees: _tachesAssignees,
                          documents: documents, // Ajout des documents
                        );
                        BoutonService().btnAjouterReunion(
                            _formKey,
                            context,
                            nouvelleReunion);
                      },
                      child: const Text('Ajouter la réunion'),
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
