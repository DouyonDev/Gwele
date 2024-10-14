import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Client.dart';
import 'package:gwele/Models/Facture.dart';
import 'package:gwele/Screens/Comptable/ajout_facture.dart';
import 'package:gwele/Services/FactureService.dart';

class DetailClient extends StatelessWidget {
  final Client clientInfo;

  const DetailClient({Key? key, required this.clientInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Les informations du client',
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
                    blocStyle(_buildFactureBlock(context)),
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
          '${clientInfo.prenom} ${clientInfo.nom}',
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
              'Téléphone : ${clientInfo.telephone}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Adresse : ${clientInfo.adresse ?? 'non renseigné'}',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const Divider( color: Colors.black,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Email : ${clientInfo.email ?? 'Non spécifiée'}',
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
  Widget _buildFactureBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Les factures :',
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
                  builder: (context) => AjoutFacture(clientId: clientInfo.id,)));
                },
                child: const Text("Ajouter une facture"),
            )
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: clientInfo.idFactures.map((participantID) {
            return FutureBuilder<Facture?>(
              future: FactureService().factureParId(participantID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Chargement...'),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    leading: Icon(Icons.error),
                    title: Text('Erreur lors du chargement de la facture'),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const ListTile(
                    leading: Icon(Icons.money),
                    title: Text('Pas de facture'),
                  );
                } else {
                  Facture? facture = snapshot.data;
                  return ListTile(
                    leading: const Icon(Icons.money),
                    title: Text(facture?.numeroFacture ?? 'Inconnu'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {

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
