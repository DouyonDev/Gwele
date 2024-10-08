import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/OrdreDuJour.dart';
import 'package:gwele/Services/OrdreDuJourService.dart'; // Assurez-vous d'importer le service correct

class AjouterOrdreDuJour extends StatefulWidget {
  final Function(String) onOrdreDuJourAjoute; // Callback pour retourner l'ID

  const AjouterOrdreDuJour({Key? key, required this.onOrdreDuJourAjoute})
      : super(key: key);

  @override
  _AjouterOrdreDuJourState createState() => _AjouterOrdreDuJourState();
}

class _AjouterOrdreDuJourState extends State<AjouterOrdreDuJour> {
  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _description = '';
  String _statut = 'en cours'; // Statut par défaut

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Créer un nouvel Ordre du Jour
      OrdreDuJour nouvelOrdre = OrdreDuJour(
        id: '', // ID sera généré par Firestore
        titre: _titre,
        description: _description,
        statut: _statut,
      );


      try {
        // Ajouter l'ordre du jour dans Firestore
        await OrdreDuJourService().ajouterOrdreDuJour(nouvelOrdre, context);

        // Appeler le callback pour retourner l'ID
        widget.onOrdreDuJourAjoute(nouvelOrdre.id);

        // Fermer la boîte de dialogue
        Navigator.of(context).pop();
      } catch (e) {
        // Gérer l'erreur ici, par exemple en affichant un message à l'utilisateur
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
            DropdownButtonFormField<String>(
              value: _statut,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: const [
                DropdownMenuItem(value: 'en cours', child: Text('En cours')),
                DropdownMenuItem(value: 'terminé', child: Text('Terminé')),
                DropdownMenuItem(value: 'annulé', child: Text('Annulé')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _statut = value;
                  });
                }
              },
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
          onPressed: _submitForm,
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
