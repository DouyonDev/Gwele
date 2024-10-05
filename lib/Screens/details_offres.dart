import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Offre.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/UtilsService.dart';

class DetailOffre extends StatelessWidget {
  final Offre offreInfo;

  const DetailOffre({Key? key, required this.offreInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Détails de l\'offre',
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
                    // Deuxième Bloc: Liste des documents
                    blocStyle(_buildDocumentsBlock()),
                    const SizedBox(height: 20),
                    // Quatrième Bloc: Description de l'offre
                    blocStyle(_buildDescriptionBlock()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
          offreInfo.titre ?? 'Sans titre',
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
              'Date limite: ${offreInfo.dateLimite != null ? UtilsService().formatDate(DateTime.parse(offreInfo.dateLimite.toString())) : 'Date non disponible'}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Statut : ${offreInfo.statut ?? 'Statut inconnu'}',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Soumis par : ${offreInfo.soumisPar ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 12.0,
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
  Widget _buildDescriptionBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          offreInfo.description ?? 'Non spécifiée',
          style: const TextStyle(
            fontSize: 12.0,
          ),
        ),
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
        if (offreInfo.documents.isNotEmpty)
          ...offreInfo.documents.map((document) {
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


}
