import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/OrdreDuJour.dart';
import 'package:gwele/Services/OrdreDuJourService.dart';

class AjouterOrdreDuJour extends StatefulWidget {
  final Function(String) onOrdreDuJourAjoute;

  const AjouterOrdreDuJour({Key? key, required this.onOrdreDuJourAjoute})
      : super(key: key);

  @override
  _AjouterOrdreDuJourState createState() => _AjouterOrdreDuJourState();
}

class _AjouterOrdreDuJourState extends State<AjouterOrdreDuJour> {
  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _description = '';
  Duration _duree = const Duration(minutes: 10); // Durée par défaut

  void BtnAjouterOrdreDuJour() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      OrdreDuJour nouvelOrdre = OrdreDuJour(
        id: '',
        titre: _titre,
        description: _description,
        statut: 'en cours', // Statut par défaut
        duree: _duree,
        decisionsIds: [],
      );

      try {
        String ordreId = await OrdreDuJourService().ajouterOrdreDuJour(nouvelOrdre, context);

        widget.onOrdreDuJourAjoute(ordreId);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'ordre du jour: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un Ordre du Jour'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
              onSaved: (value) => _titre = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
            Row(
              children: [
                const Text('Durée:'),
                Expanded(
                  child: Slider(
                    value: _duree.inMinutes.toDouble(),
                    min: 5,
                    max: 240,
                    divisions: 23,
                    label: '${_duree.inMinutes} minutes',
                    onChanged: (value) {
                      setState(() {
                        _duree = Duration(minutes: value.toInt());
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: BtnAjouterOrdreDuJour,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: const Text(
            'Ajouter',
            style: TextStyle(color: thirdColor),
          ),
        ),
      ],
    );
  }
}
