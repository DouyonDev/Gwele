import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Screens/Comptable/ajout_Client.dart';
import 'package:gwele/Screens/Participant/ajout_offre.dart';
import 'package:gwele/Screens/Widgets/affichage_offre.dart';

import '../../Colors.dart';
import '../../Models/Client.dart';
import '../../Models/Offre.dart';
import '../Widgets/AppBarListPage.dart';
import '../Widgets/affichage_client.dart';
import '../widgets/boutons_filtre.dart';

class LesClients extends StatefulWidget {
  @override
  _LesClientsState createState() => _LesClientsState();
}

class _LesClientsState extends State<LesClients> {
  String selectedStatus = 'tout'; // Par défaut, on affiche tous les tickets

  void _updateStatus(String status) {
    setState(() {
      selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Les clients'),
        ),
        body: const Center(
            child: Text(
                'Vous devez être connecté pour voir les clients.',
                style: TextStyle(
                  color: thirdColor,
                ),
            )
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBarListPage(
        title: 'Les clients',
        buttonText: 'Ajouter',
        onButtonPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutClient(),
            ),
          );
        },
      ),
      // Ajout des boutons de filtre
      body: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterButton(
                    label: 'Toutes',
                    status: 'tout',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                  FilterButton(
                    label: 'En attente',
                    status: 'En attente',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                  FilterButton(
                    label: 'En cours',
                    status: 'En cours',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                  FilterButton(
                    label: 'Soumise',
                    status: 'Soumise',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                  FilterButton(
                    label: 'Expirée',
                    status: 'Expiree',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getClientStream(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor,));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors de la récupération des clients.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucun client trouvé.',
                          style: TextStyle(
                            color: secondaryColor,
                          ),
                      )
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    Client client = Client.fromMap(data, doc.id); // Création de l'objet Client
                    return AffichageClient(clientData: client); // Passez l'objet Client ici
                  }).toList(),
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  // 4. Fonction pour obtenir les taches en fonction du statut sélectionné
  Stream<QuerySnapshot> getClientStream(User user) {
    if (selectedStatus == 'tout') {
      return FirebaseFirestore.instance
          .collection('clients')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('clients')
          //.where('statut', isEqualTo: selectedStatus) // Filtrer par statut
          .snapshots();
    }
  }


}
