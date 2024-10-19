import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Screens/Widgets/ordre_du_jour_list.dart';

class AfficherOrdresDuJourParReunionWidget extends StatelessWidget {
  final String reunionId; // ID de la réunion pour récupérer l'ordre du jour

  const AfficherOrdresDuJourParReunionWidget({Key? key, required this.reunionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //print("ID de la réunion: $reunionId");

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('reunions').doc(reunionId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: primaryColor); // Indicateur de chargement
        }
        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Pas d\'ordre du jour pour cette réunion.');
        }

        // Récupération des IDs d'ordres du jour depuis le document de la réunion
        var reunionData = snapshot.data!.data() as Map<String, dynamic>?;


        List<dynamic>? ordreDuJourIdsFromDoc = reunionData?['ordreDuJour'];

        // Vérifie que c'est bien une liste avant de continuer
        if (ordreDuJourIdsFromDoc is List<dynamic>) {
          List<String>? ordreDuJourIds = ordreDuJourIdsFromDoc.map((id) => id.toString()).toList();

          if (ordreDuJourIds.isEmpty) {
            return const Text('Pas d\'ordre du jour pour cette réunion.');
          }

          return OrdreDuJourList(ordreDuJourIDs: ordreDuJourIds);
        } else {
          return const Text('Format des données incorrect.');
        }

        /*return FutureBuilder<List<DocumentSnapshot>>(
          future: _getOrdresDuJourDetails(ordreDuJourIds),
          builder: (context, ordresSnapshot) {
            if (ordresSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: primaryColor);
            }
            if (ordresSnapshot.hasError) {
              return Text('Erreur: ${ordresSnapshot.error}');
            }
            if (!ordresSnapshot.hasData || ordresSnapshot.data!.isEmpty) {
              return const Text('Pas d\'ordre du jour trouvé.');
            }

            // Affiche les ordres du jour récupérés
            return ListView.builder(
              shrinkWrap: true,
              itemCount: ordresSnapshot.data!.length,
              itemBuilder: (context, index) {
                var ordreDuJourData = ordresSnapshot.data![index].data() as Map<String, dynamic>?;
                return ListTile(
                  title: Text(
                    '- '+ordreDuJourData?['titre'] ?? 'Pas d\'ordre du jour',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  subtitle: Text(
                    '', // Vous pouvez personnaliser ceci avec d'autres champs
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[500]),
                  ),
                );
              },
            );
          },
        );*/
      },
    );
  }

  // Fonction pour récupérer les détails de chaque ordre du jour
  Future<List<DocumentSnapshot>> _getOrdresDuJourDetails(List<dynamic> ordreDuJourIds) async {
    List<DocumentSnapshot> ordresDuJour = [];

    // Récupération de chaque document ordre du jour par son ID
    for (String id in ordreDuJourIds) {
      DocumentSnapshot ordreDuJourDoc = await FirebaseFirestore.instance.collection('ordresDuJour').doc(id).get();
      ordresDuJour.add(ordreDuJourDoc);
    }

    return ordresDuJour;
  }
}
