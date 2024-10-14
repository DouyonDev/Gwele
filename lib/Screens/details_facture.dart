import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Models/Paiement.dart';
import 'package:gwele/Screens/Comptable/ajout_paiement.dart';
import 'package:gwele/Services/PaiementService.dart';

class DetailFacture extends StatefulWidget {
  final Facture factureInfo;

  const DetailFacture({Key? key, required this.factureInfo}) : super(key: key);

  @override
  _DetailFactureState createState() => _DetailFactureState();
}

class _DetailFactureState extends State<DetailFacture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Les informations sur la facture',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded( // Utiliser Expanded pour faire occuper l'espace restant
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Premier Bloc: Titre, Date, Statut, Heure, Salle
                    blocStyle(_buildFirstBlock()),
                    const SizedBox(height: 20),
                    // Deuxième Bloc: Liste des ordres du jour
                    blocStyle(_buildPaiementBlock(context)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premier Bloc: Titre, Date, Statut, Heure, Salle
  Widget _buildFirstBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.factureInfo.numeroFacture}',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payé : ${widget.factureInfo.estPaye}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Montant : ${widget.factureInfo.montant ?? 'non renseigné'}',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date écheance : ${widget.factureInfo.dateEcheance ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 12.0,
                color: secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  // Deuxième Bloc: Liste des factures
  Widget _buildPaiementBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Les paiements :',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjoutPaiement(facture: widget.factureInfo),
                  ),
                ).then((_) {
                  setState(() {}); // Actualisez l'état après le retour
                });
              },
              child: const Text("Ajouter un paiement"),
            )
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: widget.factureInfo.idPaiements.map((paiementID) {
            return FutureBuilder<Paiement?>(
              future: PaiementService().paiementParId(paiementID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Chargement...'),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    leading: Icon(Icons.error),
                    title: Text('Erreur lors du chargement du paiement'),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const ListTile(
                    leading: Icon(Icons.money),
                    title: Text('Pas de pas de paiement'),
                  );
                } else {
                  Paiement? paiement = snapshot.data;
                  return ListTile(
                    leading: const Icon(Icons.money),
                    title: Text(paiement?.montant.toString() ?? '0'+ ' FCFA'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        // Logique pour supprimer la facture
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

  // Bloc Style
  Widget blocStyle(Widget bloc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: thirdColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: bloc,
      ),
    );
  }
}
