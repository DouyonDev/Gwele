import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Tache.dart';
import 'package:gwele/Screens/Participant/modifier_tache.dart';
import 'package:gwele/Screens/Widgets/user_info_widget.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/TacheService.dart';
import 'package:gwele/Services/UtilsService.dart';

import 'Widgets/confirmation_dialog.dart';

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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    blocStyle(_buildFirstBlock()),
                    const SizedBox(height: 20),
                    blocStyle(_buildDescriptionBlock()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildActionBlock(context),
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
        const Divider(color: Colors.black),
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
                UserInfoWidget(userId: tacheInfo.assigneA, size: 10),
              ],
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
          tacheInfo.description ?? 'Non spécifiée',
          style: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  // Bloc pour les actions (modifier, supprimer, changer statut)
  Widget _buildActionBlock(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (tacheInfo.assignePar == AuthService().idUtilisateurConnect()) ...[
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                    title: 'Suppression de la tâche',
                    content: 'Voulez-vous supprimer cette tâche ?',
                    onConfirm: () {
                      TacheService().supprimerTache(tacheInfo.id);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reunion supprimé')),
                      );
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    }
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Logique pour modifier la tâche
              _editTask(context);
            },
          ),
        ],
        if (tacheInfo.assigneA == AuthService().idUtilisateurConnect()) ...[
          if (tacheInfo.statut != "Terminer") ...[
            ElevatedButton(
              //icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                // Logique pour marquer la tâche comme terminée
                _updateTaskStatus("Terminer",context);
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('Terminer'),
            ),
          ],
          if (tacheInfo.statut != "En cours") ...[
            ElevatedButton(
              //icon: const Icon(Icons.play_arrow, color: Colors.orange),
              onPressed: () {
                // Logique pour marquer la tâche comme en cours
                _updateTaskStatus("En cours", context);
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('En cours'),
            ),
          ]
        ],
      ],
    );
  }


  Future<void> _editTask(BuildContext context) async {
    // Implémentez ici la logique de modification
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> ModifierTache(tache: tacheInfo)));
    print('Modifier la tâche');
  }

  Future<void> _updateTaskStatus(String status,BuildContext context) async {
    tacheInfo.statut = status;
    TacheService().mettreAJourTache(tacheInfo);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tache $status')),
    );
    // Implémentez ici la logique de mise à jour du statut
    print('Statut de la tâche mis à jour : $status');
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
