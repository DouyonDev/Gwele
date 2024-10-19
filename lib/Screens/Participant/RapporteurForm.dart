import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/OrdreDuJour.dart';
import 'package:gwele/Services/OrdreDuJourService.dart';

class RapporteurForm extends StatefulWidget {
  final List<String> ordresDuJour; // Liste des ordres du jour
  //final Function(String ordreDuJour, String notes, String decisions, List<String> tachesAssignees) onSubmit;

  const RapporteurForm({Key? key, required this.ordresDuJour/*, required this.onSubmit*/}) : super(key: key);

  @override
  _RapporteurFormState createState() => _RapporteurFormState();
}

class _RapporteurFormState extends State<RapporteurForm> {
  String? _selectedOrdreDuJour;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _decisionsController = TextEditingController();
  final TextEditingController _tachesController = TextEditingController();
  List<String> _tachesAssignees = [];

  void _assignTache() {
    if (_tachesController.text.isNotEmpty) {
      setState(() {
        _tachesAssignees.add(_tachesController.text);
        _tachesController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          hint: const Text('Sélectionner un ordre du jour'),
          value: _selectedOrdreDuJour,
          onChanged: (String? newValue) {
            setState(() {
              _selectedOrdreDuJour = newValue;
            });
          },
          items: widget.ordresDuJour.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: FutureBuilder<OrdreDuJour?>(
                future: OrdreDuJourService().ordreDuJourParId(value),
                builder: (BuildContext context, AsyncSnapshot<OrdreDuJour?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Ou n'importe quel indicateur de chargement
                  } else if (snapshot.hasError) {
                    return Text('Erreur : ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Text('Aucun ordre du jour trouvé');
                  } else {
                    return Text(snapshot.data!.titre);
                  }
                },
              ),
            );
          }).toList(),
        ),
        if (_selectedOrdreDuJour != null) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Prendre des notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _decisionsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Décisions prises',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tachesController,
            decoration: const InputDecoration(
              labelText: 'Assigner une tâche',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _assignTache,
            child: const Text('Ajouter la tâche'),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: _tachesAssignees.map((tache) {
              return Chip(
                label: Text(tache),
                onDeleted: () {
                  setState(() {
                    _tachesAssignees.remove(tache);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_selectedOrdreDuJour != null) {
                /*widget.onSubmit(
                  _selectedOrdreDuJour!,
                  _notesController.text,
                  _decisionsController.text,
                  _tachesAssignees,
                );*/
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélectionnez un ordre du jour')),
                );
              }
            },
            child: const Text('Soumettre le rapport'),
          ),
        ],
      ],
    );
  }
}
