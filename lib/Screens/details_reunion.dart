import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/OrdreDuJour.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Tache.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Lead/ModifierReunion.dart';
import 'package:gwele/Screens/Lead/ajout_tache_reunion.dart';
import 'package:gwele/Screens/Widgets/FirstBlockReunion.dart';
import 'package:gwele/Screens/Widgets/bottom_block_widget.dart';
import 'package:gwele/Screens/Widgets/message_modale.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/OrdreDuJourService.dart';
import 'package:gwele/Services/ReunionService.dart';
import 'package:gwele/Services/TacheService.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/UtilsService.dart';

class DetailReunion extends StatefulWidget {
  final Reunion reunionInfo;

  const DetailReunion({Key? key, required this.reunionInfo}) : super(key: key);

  @override
  DetailReunionState createState() => DetailReunionState();
}

class DetailReunionState extends State<DetailReunion> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Détails de la réunion',
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
                    blocStyle(FirstBlockReunion(reunionInfo: widget.reunionInfo)),
                    const SizedBox(height: 20),
                    // Deuxième Bloc: Liste des ordres du jour
                    blocStyle(_buildOrdreDuJourBlock()),
                    const SizedBox(height: 20),
                    // Troisième Bloc: Liste des participants
                    blocStyle(_buildParticipantsBlock()),
                    const SizedBox(height: 20),
                    // Quatrième Bloc: Liste des documents
                    blocStyle(_buildDocumentsBlock()),
                    const SizedBox(height: 20),
                    // Quatrième Bloc: Liste des documents
                    if(widget.reunionInfo.statut == "En cours")
                      blocStyle(_buildTachesBlock()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // IconButton pour uploader des documents, en dehors du SingleChildScrollView
            Column(
              children: [
                botomStyle(BottomBlockReunion(reunionInfo: widget.reunionInfo,)),
              ]
            )
          ],
        ),
      ),
    );
  }


  // Deuxième Bloc: Liste des ordres du jour
  Widget _buildOrdreDuJourBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liste des ordres du jour :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: widget.reunionInfo.ordreDuJour.map((ordreDuJourID) {
            return FutureBuilder<OrdreDuJour?>(
              future: OrdreDuJourService().ordreDuJourParId(ordreDuJourID),//.ordreDuJourParId(paiementID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Chargement...'),
                  );
                } else if (snapshot.hasError) {
                  return const ListTile(
                    leading: Icon(Icons.error),
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
                    leading: const Icon(Icons.money),
                    title: Text(ordreDuJour?.titre ?? 'Sans titre'),
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

  // Troisième Bloc: Liste des participants
  Widget _buildParticipantsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participants :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Vérifie si la liste des participants n'est pas vide
        if (widget.reunionInfo.participants.isNotEmpty)
          ...widget.reunionInfo.participants.map((participantId) {
            // Retourner un FutureBuilder pour chaque participant
            return FutureBuilder<Utilisateur?>(
              future: UtilisateurService().utilisateurParId(participantId), // Cherche les informations du participant à partir de son id
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Affichez un indicateur de chargement pendant la récupération des données
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Gérer les erreurs si la récupération échoue
                  return const Text('Erreur de chargement');
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Si les données sont disponibles, afficher le ListTile
                  Utilisateur infoParticipant = snapshot.data!;
                  return ListTile(
                    leading: const Icon(Icons.person, color: secondaryColor),
                    title: Text(
                      '${infoParticipant.prenom} ${infoParticipant.nom}', // Afficher prénom et nom
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    trailing: const Icon(Icons.person_outline, color: Colors.blueGrey),
                  );
                } else {
                  return const Text('Participant non trouvé');
                }
              },
            );
          }).toList()
        else
          const Text('Aucun participant'),
      ],
    );
  }



  // Quatrième Bloc: Liste des documents
  Widget _buildDocumentsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documents :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Vérifie si la liste des documents n'est pas vide
        if (widget.reunionInfo.documents.isNotEmpty)
          ...widget.reunionInfo.documents.map((document) {
            String documentUrl = document; // Supposons que l'URL est stockée sous 'url'
            String fileName = _getFileNameFromUrl(documentUrl);

            // Afficher un ListTile pour chaque document
            return ListTile(
              leading: const Icon(Icons.insert_drive_file, color: secondaryColor),
              title: Text(
                fileName, // Afficher le nom du fichier extrait de l'URL
                style: const TextStyle(fontSize: 16.0),
              ),
            );
          }).toList()
        else
          const Text('Aucun document'),
      ],
    );
  }

  Widget _buildTachesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Les tâches :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Vérifie si la liste des participants n'est pas vide
        if (widget.reunionInfo.tachesAssignees.isNotEmpty)
          ...widget.reunionInfo.tachesAssignees.map((tacheId) {
            // Retourner un FutureBuilder pour chaque participant
            return FutureBuilder<Tache?>(
              future: TacheService().tacheParId(tacheId), // Cherche les informations du participant à partir de son id
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Affichez un indicateur de chargement pendant la récupération des données
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Gérer les erreurs si la récupération échoue
                  return const Text('Erreur de chargement');
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Si les données sont disponibles, afficher le ListTile
                  Tache infoTache = snapshot.data!;
                  return ListTile(
                    leading: const Icon(Icons.person, color: secondaryColor),
                    title: Text(
                      '${infoTache.titre} ${infoTache.statut}', // Afficher prénom et nom
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    trailing: const Icon(Icons.person_outline, color: Colors.blueGrey),
                  );
                } else {
                  return const Text('Tache non trouvé');
                }
              },
            );
          }).toList()
        else
          const Text('Aucune tâche'),
      ],
    );
  }

// Fonction pour extraire le nom du fichier à partir de l'URL
  String _getFileNameFromUrl(String url) {
    // Si l'URL est au format standard, on peut extraire le nom
    Uri uri = Uri.parse(url);
    String path = uri.path; // Obtient le chemin de l'URL
    String fileName = path.substring(path.lastIndexOf('/') + 1); // Extrait le nom du fichier
    return fileName; // Retourne le nom du fichier
  }

  // Bloc Style
  Widget blocStyle(Widget bloc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
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

  // Bloc Style
  Widget botomStyle(Widget bloc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
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
