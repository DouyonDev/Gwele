import 'package:flutter/material.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Screens/details_facture.dart';

class AffichageFacture extends StatelessWidget {
  final Facture factureData;

  AffichageFacture({required this.factureData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailFacture(factureInfo: factureData,),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          leading: const Icon(Icons.money),
          title: Text(factureData.numeroFacture ?? 'Inconnu'),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              // Logique pour supprimer la facture
            },
          ),
        ),
        ),
      );
  }
}
