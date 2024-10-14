import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Models/Paiement.dart';
import 'package:gwele/Services/PaiementService.dart';

class AjoutPaiement extends StatefulWidget {
  final Facture facture; // ID de la facture associée

  const AjoutPaiement({Key? key, required this.facture}) : super(key: key);

  @override
  _AjouterPaiementState createState() => _AjouterPaiementState();
}

class _AjouterPaiementState extends State<AjoutPaiement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montantController = TextEditingController();
  String _modePaiement = 'Espèces'; // Valeur par défaut
  DateTime _datePaiement = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Ajouter un Paiement',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _montantController,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final montant = double.tryParse(value);
                  if (montant == null || montant <= 0) {
                    return 'Veuillez entrer un montant valide (positif)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _modePaiement,
                decoration: const InputDecoration(
                  labelText: 'Mode de Paiement',
                  border: OutlineInputBorder(),
                ),
                items: ['Espèces', 'Carte', 'Virement']
                    .map((mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _modePaiement = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un mode de paiement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _ajouterPaiement();
                  }
                },
                child: const Text('Ajouter Paiement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ajouterPaiement() async {
    final double montant = double.parse(_montantController.text);
    final Paiement paiement = Paiement(
      id: '', // L'ID sera généré par Firestore
      montant: montant,
      datePaiement: _datePaiement,
      modePaiement: _modePaiement,
      idFacture: widget.facture.id,
    );

    try {
      await PaiementService().ajouterPaiement(paiement, widget.facture);
      Navigator.pop(context); // Retourner à la page précédente après ajout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement ajouté')),
      );
    } catch (e) {
      print('Erreur lors de l\'ajout du paiement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du paiement')),
      );
    }
  }
}
