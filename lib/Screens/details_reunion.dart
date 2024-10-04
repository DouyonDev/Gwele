import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Services/UtilisateurService.dart';

class DetailReunionPage extends StatelessWidget {
  final Reunion reunionInfo;

  const DetailReunionPage({Key? key, required this.reunionInfo}) : super(key: key);

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
        child: SingleChildScrollView( // Utiliser SingleChildScrollView pour éviter les erreurs de layout
          child: Column(
            children: [
              // Premier Bloc: Titre, Date, Statut, Heure, Salle
              _buildFirstBlock(),

              const SizedBox(height: 20),

              // Deuxième Bloc: Liste des ordres du jour
              _buildOrdreDuJourBlock(),

              const SizedBox(height: 20),

              // Troisième Bloc: Liste des participants
              _buildParticipantsBlock(),

              const SizedBox(height: 20),

              // Quatrième Bloc: Liste des documents
              _buildDocumentsBlock(),

              const SizedBox(height: 20),

              // IconButton pour uploader des documents
              if (reunionInfo.statut == "En attente")
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.upload_file, color: primaryColor),
                    onPressed: () {
                      // Logique pour uploader les documents
                    },
                  ),
                ),
            ],
          ),
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
          reunionInfo.titre ?? 'Sans titre',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Date : ${reunionInfo.dateReunion ?? 'Date non disponible'}',
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Divider(),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Heure : ${reunionInfo.heureDebut ?? 'Non spécifiée'} - ${reunionInfo.heureFin ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            Text(
              'Salle : ${reunionInfo.lieu ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'Statut : ${reunionInfo.statut ?? 'Statut inconnu'}',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: reunionInfo.statut == 'resolu' ? Colors.green : Colors.red,
          ),
        ),
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
        if (reunionInfo.ordreDuJour.isNotEmpty)
          for (var ordre in reunionInfo.ordreDuJour)
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
        if (reunionInfo.participants.isNotEmpty)
          ...reunionInfo.participants.map((participantId) {
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
        if (reunionInfo.documents.isNotEmpty)
          ...reunionInfo.documents.map((document) {
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

// Fonction pour extraire le nom du fichier à partir de l'URL
  String _getFileNameFromUrl(String url) {
    // Si l'URL est au format standard, on peut extraire le nom
    Uri uri = Uri.parse(url);
    String path = uri.path; // Obtient le chemin de l'URL
    String fileName = path.substring(path.lastIndexOf('/') + 1); // Extrait le nom du fichier
    return fileName; // Retourne le nom du fichier
  }


}
