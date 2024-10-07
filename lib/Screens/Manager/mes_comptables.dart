import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Manager/ajout_Comptable.dart';
import 'package:gwele/Screens/Manager/ajout_equipe.dart';
import 'package:gwele/Screens/Participant/ajout_offre.dart';
import 'package:gwele/Screens/Participant/ajout_tache.dart';
import 'package:gwele/Screens/Widgets/affichage_comptable.dart';
import 'package:gwele/Screens/Widgets/affichage_equipe.dart';
import 'package:gwele/Screens/Widgets/affichage_offre.dart';
import 'package:gwele/Screens/Widgets/affichage_tache.dart';

import '../../Colors.dart';
import '../../Models/Equipe.dart';
import '../../Models/Offre.dart';
import '../../Models/Tache.dart';
import '../Widgets/AppBarListPage.dart';
import '../widgets/boutons_filtre.dart';

class MesComptables extends StatefulWidget {
  @override
  _MesComptablesState createState() => _MesComptablesState();
}

class _MesComptablesState extends State<MesComptables> {
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
            title: const Text('Vos Comptables')
        ),
        body: const Center(
            child: Text(
                'Vous devez être connecté pour voir les comptables que vous avez ajoutées',
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
        title: 'Vos Comptables',
        buttonText: 'Ajouter',
        onButtonPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjoutComptable(),
            ),
          );
        },
      ),
      // Ajout des boutons de filtre
      body: Column(
        children: [
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
                          'Erreur lors de la récupération de vos comptablles.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucun comptable trouvé provenant de vous.',
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
                    Utilisateur comptable = Utilisateur.fromDocument(data, doc.id);
                    print("les équipes");
                    print(Equipe);
                    return AffichageComptable(comptableData: comptable); // Passez l'objet Reunion ici
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
          .collection('utilisateurs')
          .where('userMere', isEqualTo: user.uid) // Vérifier si l'utilisateur est dans les participants
          .where('role', isEqualTo: "COMPTABLE")
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('utilisateurs')
          .where('userMere', isEqualTo: user.uid) // Vérifier si l'utilisateur est dans les participants
          .where('role', isEqualTo: "COMPTABLE")
          //.where('statut', isEqualTo: selectedStatus) // Filtrer par statut
          .snapshots();
    }
  }


}
