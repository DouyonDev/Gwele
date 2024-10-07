import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Screens/Lead/ajout_reunion.dart';

import '../../Colors.dart';
import '../Participant/mes_reunions_calendar.dart';
import '../Widgets/AppBarListPage.dart';
import '../widgets/affichage_reunion.dart';
import '../widgets/boutons_filtre.dart';

class LesReunions extends StatefulWidget {
  @override
  _LesReunionsState createState() => _LesReunionsState();
}

class _LesReunionsState extends State<LesReunions> {
  String selectedStatus = 'En attente'; // Par défaut, on affiche tous les tickets

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
        appBar: AppBar(title: const Text('Liste des réunions')),
        body: const Center(
            child: Text(
                'Vous devez être connecté pour voir les réunions auxquelles vous avez participez.',
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
        title: 'Liste des reunions',
        buttonText: 'Ajouter',
        onButtonPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutReunion(),
            ),
          );
        },
      ),

      // Ajout des boutons de filtre
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterButton(
                label: 'Programmer',
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
                label: 'Terminer',
                status: 'Terminer',
                selectedStatus: selectedStatus,
                onStatusSelected: _updateStatus,
              ),
              IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReunionCalendarPage(),
                  ),
                );
              }, icon:  const Icon(Icons.calendar_month), )
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getReunionsStream(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor,));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors de la récupération des réunions.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucune réunion trouvée.',
                          style: TextStyle(
                            color: secondaryColor,
                          ),
                      )
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Créez un objet Reunion à partir des données
                    final reunion = Reunion.fromDocument(data, doc.id);
                    return AffichageReunion(reunionData: reunion); // Passez l'objet Reunion ici
                  }).toList(),
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  // 4. Fonction pour obtenir les tickets en fonction du statut sélectionné
  Stream<QuerySnapshot> _getReunionsStream(User user) {
    if (selectedStatus == 'En attente') {
      // Filtrer toutes les réunions où l'utilisateur est un participant
      return FirebaseFirestore.instance
          .collection('reunions')
          //.where('participants', arrayContains: user.uid) // Vérifier si l'utilisateur est dans les participants
          .where('statut', isEqualTo: 'En attente')
          .snapshots();
    } else {
      // Filtrer par statut et vérifier si l'utilisateur est un participant
      return FirebaseFirestore.instance
          .collection('reunions')
          //.where('participants', arrayContains: user.uid) // Vérifier si l'utilisateur est dans les participants
          .where('statut', isEqualTo: selectedStatus) // Filtrer par statut
          .snapshots();
    }
  }


}
