import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Screens/Participant/ajout_tache.dart';
import 'package:gwele/Screens/Widgets/affichage_tache.dart';
import 'package:stream_transform/stream_transform.dart'; // Importer le package

import '../../Colors.dart';
import '../../Models/Tache.dart';
import '../Widgets/AppBarListPage.dart';
import '../widgets/boutons_filtre.dart';

class LesTaches extends StatefulWidget {
  @override
  _LesTachesState createState() => _LesTachesState();
}

class _LesTachesState extends State<LesTaches> {
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
            title: const Text('Les tâches')
        ),
        body: const Center(
            child: Text(
                'Vous devez être connecté pour voir les tâches auxqelles vous êtes assigées',
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
        title: 'Les tâches',
        buttonText: 'Ajouter',
        onButtonPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutTache(),
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
                    label: 'Haute',
                    status: 'haute',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                  FilterButton(
                    label: 'Moyenne',
                    status: 'moyenne',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                  FilterButton(
                    label: 'Basse',
                    status: 'basse',
                    selectedStatus: selectedStatus,
                    onStatusSelected: _updateStatus,
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getTacheManager(user, selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor,));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors de la récupération des tâches.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucune tâche trouvée.',
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
                    Tache tache = Tache.fromDocument(data, doc.id);
                    print("les taches");
                    print(tache.assigneA);
                    return AffichageTache(tacheData: tache); // Passez l'objet Reunion ici
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
  Stream<QuerySnapshot> getTacheManager(User user, String selectedStatus) {
    // Filtrer les tâches assignées à l'utilisateur selon le statut
    Stream<QuerySnapshot> tachesAssigneesA;
    Stream<QuerySnapshot> tachesAssigneesPar;

    if (selectedStatus == 'tout') {
      tachesAssigneesA = FirebaseFirestore.instance
          .collection('taches')
          .where('assigneA', isEqualTo: user.uid)
          .snapshots();

      tachesAssigneesPar = FirebaseFirestore.instance
          .collection('taches')
          .where('assignePar', isEqualTo: user.uid)
          .snapshots();
    } else {
      tachesAssigneesA = FirebaseFirestore.instance
          .collection('taches')
          .where('assigneA', isEqualTo: user.uid)
          .where('priorite', isEqualTo: selectedStatus)
          .snapshots();

      tachesAssigneesPar = FirebaseFirestore.instance
          .collection('taches')
          .where('assignePar', isEqualTo: user.uid)
          .where('priorite', isEqualTo: selectedStatus)
          .snapshots();
    }

    // Utiliser `merge` pour combiner les deux flux
    return tachesAssigneesA.merge(tachesAssigneesPar);
  }






}
