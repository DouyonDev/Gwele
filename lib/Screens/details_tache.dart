import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Widgets/user_info_widget.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/UtilsService.dart';

import '../Models/Tache.dart';

class DetailTache extends StatelessWidget {
  final Tache tacheInfo;

  const DetailTache({Key? key, required this.tacheInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Détails de la tâche',
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
          tacheInfo.titre ?? 'Sans titre',
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
              'Date d\'écheance : ${tacheInfo.dateLimite != null ? UtilsService().formatDate(DateTime.parse(tacheInfo.dateLimite.toString())) : 'Date non disponible'}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Statut : ${tacheInfo.statut ?? 'Statut inconnu'}',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const Divider( color: Colors.black,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Priorité : ${tacheInfo.priorite ?? 'Non spécifiée'}',
              style: const TextStyle(
                fontSize: 12.0,
                color: secondaryColor,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Responsable : ',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: secondaryColor,
                  ),
                ),
                UserInfoWidget(userId : tacheInfo.assigneA,size: 10,),
              ],
            )

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
          tacheInfo.description ?? 'Non spécifiée',
          style: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }


  // Bloc Style
  Widget blocStyle(Widget bloc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: thirdColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.5),
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
