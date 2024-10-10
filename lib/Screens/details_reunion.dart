import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Lead/ModifierReunion.dart';
import 'package:gwele/Screens/Widgets/message_modale.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/UtilsService.dart';

import '../Services/BoutonService.dart';
import '../Services/ReunionService.dart';
import 'Widgets/affichage_boutons_selection_participant.dart';

class DetailReunion extends StatefulWidget {
  final Reunion reunionInfo;

  const DetailReunion({Key? key, required this.reunionInfo}) : super(key: key);

  @override
  DetailReunionState createState() => DetailReunionState();
}


class DetailReunionState extends State<DetailReunion> {

  Future<QuerySnapshot> getParticipants(String reunionId) async {
    // Récupérer le document de la réunion par son ID
    DocumentSnapshot reunionDoc = await FirebaseFirestore.instance
        .collection('reunions')
        .doc(reunionId)
        .get();

    if (!reunionDoc.exists) {
      throw Exception("La réunion n'existe pas.");
    }

    // Récupérer la liste des IDs des participants (assumée comme un champ 'participants')
    List<dynamic> participantIds = reunionDoc['participants'] ?? [];

    if (participantIds.isEmpty) {
      throw Exception("Aucun participant trouvé.");
    }

    // Récupérer les utilisateurs en fonction de leurs IDs
    return await FirebaseFirestore.instance
        .collection('utilisateurs')
        .where(FieldPath.documentId, whereIn: participantIds)
        .get();
  }
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
                    blocStyle(_buildFirstBlock()),
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
                  ],
                ),
              ),
            ),
            // IconButton pour uploader des documents, en dehors du SingleChildScrollView
            Column(
              children: [
                botomStyle(_buildBottomBlock()),
              ]
            )
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
          widget.reunionInfo.titre ?? 'Sans titre',
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
              'Date : ${widget.reunionInfo.dateReunion != null ? UtilsService().formatDate(DateTime.parse(widget.reunionInfo.dateReunion.toString())) : 'Date non disponible'}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Statut : ${widget.reunionInfo.statut ?? 'Statut inconnu'}',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: widget.reunionInfo.statut == 'resolu' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Debut : ${widget.reunionInfo.heureDebut.hour ?? 'Non spécifiée'}:${widget.reunionInfo.heureDebut.minute ?? 'Non spécifiée'} -'
                  ' Fin : ${widget.reunionInfo.heureFin.hour ?? 'Non spécifiée'}:${widget.reunionInfo.heureFin.minute ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            Text(
              'Salle : ${widget.reunionInfo.lieu ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
      ],
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
        if (widget.reunionInfo.ordreDuJour.isNotEmpty)
          for (var ordre in widget.reunionInfo.ordreDuJour)
            ListTile(
              leading: const Icon(Icons.check, color: secondaryColor),
              title: Text(
                ordre, // Utiliser directement le texte de l'ordre du jour
                style: const TextStyle(fontSize: 16.0),
              ),
            )
        else
          const Text('Aucun ordre du jour'),
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

  // Quatrième Bloc: Liste des documents
  Widget _buildBottomBlock() {
    String? userId = AuthService().idUtilisateurConnect();
    return Row(
      children: [
        if (widget.reunionInfo.statut != "Archivee")
          Tooltip(
            message: "Envoyer un document",
            child: IconButton(
            icon: const Icon(Icons.upload_file, color: primaryColor),
              onPressed: () async {
                // Sélectionner le fichier et attendre le résultat
                File? fichierSelectionne = await FichiersService().selectionnerFichier();

                // Vérifier si un fichier a bien été sélectionné
                if (fichierSelectionne != null) {
                  // Appeler la méthode d'upload avec le fichier sélectionné
                  String fileName = fichierSelectionne.path.split('/').last; // Extraire le nom du fichier
                  String downloadUrl = await FichiersService().uploaderFichierReunion(fichierSelectionne, fileName);
                  setState(() {});
                  // Utiliser l'URL de téléchargement comme nécessaire
                  print('Fichier uploadé avec succès : $downloadUrl');
                } else {
                  print('Aucun fichier sélectionné.');
                }
              },
            ),
          ),
        // Nouveau bouton : Affiché seulement si l'utilisateur connecté est le créateur de la réunion
        if (widget.reunionInfo.lead == userId)
          Row(
          children: [
            Tooltip(
            message: "Modifier la réunion",
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              // Icône de modification par exemple
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ModifierReunion(reunion: widget.reunionInfo),
                  ),
                );
              },
            ),
          ),
          if(widget.reunionInfo.statut != "En cours" ||
              widget.reunionInfo.statut != "Archivee" ||
              widget.reunionInfo.statut != "Terminee")
            Tooltip(
              message: "Commencer la réunion",
              child: IconButton(
                icon: const Icon(Icons.not_started, color: Colors.blue),
                // Icône de modification par exemple
                onPressed: () async {
                  QuerySnapshot participantsSnapshot = await getParticipants(widget.reunionInfo.id); // Utilisation de fetchParticipants
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text(
                            "Veuillez Choisir un rapporteur pour commencer",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: primaryColor,
                        ),
                        body: ListView.builder(
                          itemCount: participantsSnapshot.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            // Récupérer les données du participant et l'ID du document
                            var participantData = participantsSnapshot.docs[index].data() as Map<String, dynamic>;
                            var participantId = participantsSnapshot.docs[index].id; // Récupérer l'ID du participant

                            return ListTile(
                              leading: const Icon(Icons.person, color: Colors.blueGrey),
                              title: Text(
                                '${participantData['prenom'] ?? 'Inconnu'} ${participantData['nom'] ?? 'Inconnu'}',
                                style: const TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                              subtitle: Text(participantData['email'] ?? 'Email non disponible'),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey),
                              onTap: () async {
                                try {
                                  print(participantId);
                                  // Mettre à jour le rapporteur dans l'objet réunion
                                  widget.reunionInfo.rapporteur = participantId;
                                  widget.reunionInfo.statut = "En cours"; // Mettre à jour le statut de la réunion

                                  // Mettre à jour la réunion dans la base de données
                                  await ReunionService().mettreAJourReunion(widget.reunionInfo);

                                  Navigator.pop(context); // Fermer la modale après sélection

                                  setState(() {}); // Mettre à jour l'état de l'interface

                                  // Afficher le dialogue après la mise à jour
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return MessageModale(
                                        title: widget.reunionInfo.titre,
                                        content: "La réunion a démarré.",
                                      );
                                    },
                                  );

                                  // Récupérer les informations de l'utilisateur par son ID
                                  Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(participantId);

                                  // Afficher le SnackBar avec le nom du rapporteur sélectionné
                                  if (utilisateur != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Rapporteur sélectionné: ${utilisateur.prenom} ${utilisateur.nom}')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Utilisateur non trouvé')),
                                    );
                                  }
                                } catch (e) {
                                  // Gérer les erreurs et afficher un message d'erreur
                                  print('Erreur lors de la sélection du rapporteur: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Erreur lors de la récupération du rapporteur')),
                                  );
                                }

                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },

              ),
            ),
          if (widget.reunionInfo.statut == "En cours")
            Tooltip(
              message: "Arrêtez la réunion",
              child: IconButton(
                icon: const Icon(Icons.stop, color: Colors.blue),
                // Icône de modification par exemple
                onPressed: () {
                  widget.reunionInfo.statut = "Terminer";
                  ReunionService().mettreAJourReunion(widget.reunionInfo);
                  setState(() {});
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MessageModale(
                        title: widget.reunionInfo.titre,
                        content: "La réunion a démarée.",
                      );
                    },
                  );
                },
              ),
            ),
          Tooltip(
            message: "Supprimer la réunion",
            child: IconButton(
              icon: const Icon(
                  Icons.delete_outline_rounded, color: Colors.blue),
              onPressed: () {
                widget.reunionInfo.statut = "En cours";
                ReunionService().supprimerReunion(widget.reunionInfo.id);
                setState(() {});
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MessageModale(
                      title: widget.reunionInfo.titre,
                      content: "La reunion a été définitivement supprimée.",
                    );
                  },

                );
              },
            ),
          )
          ]
          )

      ]
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
