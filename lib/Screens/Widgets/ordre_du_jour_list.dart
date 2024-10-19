import 'package:flutter/material.dart';
import 'package:gwele/Models/OrdreDuJour.dart';
import 'package:gwele/Services/OrdreDuJourService.dart';

class OrdreDuJourList extends StatelessWidget {
  final List<String> ordreDuJourIDs; // Liste des identifiants d'ordres du jour

  const OrdreDuJourList({Key? key, required this.ordreDuJourIDs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ordreDuJourIDs.map((ordreDuJourID) {
        return FutureBuilder<OrdreDuJour?>(
          future: OrdreDuJourService().ordreDuJourParId(ordreDuJourID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Chargement...'),
              );
            } else if (snapshot.hasError) {
              return const ListTile(
                leading: Icon(
                    Icons.error,
                    color: Colors.red,
                ),
                title: Text('Erreur lors du chargement de l\'ordre du jour'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const ListTile(
                leading: Icon(Icons.money),
                title: Text('Pas d\'ordre du jour'),
              );
            } else {
              OrdreDuJour? ordreDuJour = snapshot.data;
              return ListTile(
                leading: const Icon(Icons.list),
                title: Text(ordreDuJour?.titre ?? 'Sans titre'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    // Logique pour supprimer l'ordre du jour
                  },
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }
}