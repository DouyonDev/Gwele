import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Client.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Services/FactureService.dart';
import 'package:intl/intl.dart';

class AjoutFacture extends StatefulWidget {
  final Client client;

  AjoutFacture({required this.client});

  @override
  _AjoutFactureState createState() => _AjoutFactureState();
}

class _AjoutFactureState extends State<AjoutFacture> {
  final _formKey = GlobalKey<FormState>();
  final FactureService _factureService = FactureService();

  TextEditingController _numeroFactureController = TextEditingController(); // Controller pour le numéro de facture
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _montantController = TextEditingController();
  DateTime? _dateEcheance;

  bool _isSaving = false;

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateEcheance) {
      setState(() {
        _dateEcheance = picked;
      });
    }
  }

  Future<void> _saveFacture() async {
    if (_formKey.currentState!.validate() && _dateEcheance != null) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Création de la facture avec le numéro saisi par l'utilisateur
        Facture facture = Facture(
          id: '',
          clientId: widget.client.id,
          numeroFacture: _numeroFactureController.text, // Numéro de facture saisi par l'utilisateur
          description: _descriptionController.text,
          montant: double.parse(_montantController.text),
          dateEmission: DateTime.now(),
          dateEcheance: _dateEcheance!,
        );

        // Enregistrement dans Firestore
        await _factureService.ajouterFacture(facture, widget.client);

        // Retour à l'écran précédent après succès
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facture ajoutée avec succès')),
        );
      } catch (e) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de la facture : $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et choisir une date d\'échéance.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une facture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ pour que l'utilisateur saisisse le numéro de facture
              TextFormField(
                controller: _numeroFactureController,
                decoration: InputDecoration(labelText: 'Numéro de Facture'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de facture';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _montantController,
                decoration: InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _dateEcheance == null
                        ? 'Choisir une date d\'échéance'
                        : 'Échéance: ${DateFormat.yMMMd().format(_dateEcheance!)}',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(context),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : ElevatedButton(
                onPressed: _saveFacture,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
