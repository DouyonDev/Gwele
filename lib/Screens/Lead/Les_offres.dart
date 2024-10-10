import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Screens/Participant/ajout_offre.dart';
import 'package:gwele/Screens/Widgets/affichage_offre.dart';

import '../../Colors.dart';
import '../../Models/Offre.dart';
import '../Widgets/AppBarListPage.dart';
import '../widgets/boutons_filtre.dart';

class LesOffres extends StatefulWidget {
  @override
  _LesOffresState createState() => _LesOffresState();
}

class _LesOffresState extends State<LesOffres> {
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
            title: const Text('Les offres')
        ),
        body: const Center(
            child: Text(
                'Vous devez être connecté pour voir les offres.',
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
        title: 'Les offres',
        buttonText: 'Ajouter',
        onButtonPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutOffre(),
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
              stream: getOffreStream(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor,));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors de la récupération de vos offres.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucune offre trouvée provenant de vous.',
                          style: TextStyle(
                            color: secondaryColor,
                          ),
                      )
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Créez un objet Tache à partir des données
                    Offre offre = Offre.fromFirestore(data, doc.id);
                    print("les taches");
                    print(offre);
                    return AffichageOffre(offreData: offre); // Passez l'objet Reunion ici
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
  Stream<QuerySnapshot> getOffreStream(User user) {
    if (selectedStatus == 'tout') {
      return FirebaseFirestore.instance
          .collection('offres')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('offres')
          .where('statut', isEqualTo: selectedStatus) // Filtrer par statut
          .snapshots();
    }
  }


}
