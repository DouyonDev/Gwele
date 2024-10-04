import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Colors.dart';
import '../widgets/affichage_reunion.dart';
import '../widgets/boutons_filtre.dart';

class MesReunions extends StatefulWidget {
  @override
  _MesReunionsState createState() => _MesReunionsState();
}

class _MesReunionsState extends State<MesReunions> {
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        //toolbarHeight: 70,
        title: const Text(
            'Liste des réunions',
        style: TextStyle(
            fontSize: 30,
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: true,
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
                status: 'Termine',
                selectedStatus: selectedStatus,
                onStatusSelected: _updateStatus,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getReunionsStream(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xffF79621),));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors de la récupération des tickets.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucun ticket trouvé.',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                      )
                  );
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id_ticket'] = doc.id;
                    return AffichageReunion(reunionData: data);
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
          .where('participants', arrayContains: user.uid) // Vérifier si l'utilisateur est dans les participants
          .snapshots();
    } else {
      // Filtrer par statut et vérifier si l'utilisateur est un participant
      return FirebaseFirestore.instance
          .collection('reunions')
          .where('participants', arrayContains: user.uid) // Vérifier si l'utilisateur est dans les participants
          .where('statut', isEqualTo: selectedStatus) // Filtrer par statut
          .snapshots();
    }
  }


}
