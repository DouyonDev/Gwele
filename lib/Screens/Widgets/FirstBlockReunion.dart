import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Services/UtilsService.dart';

class FirstBlockReunion extends StatelessWidget {
  final Reunion reunionInfo;

  const FirstBlockReunion({
    Key? key,
    required this.reunionInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date : ${reunionInfo.dateReunion != null ? UtilsService().formatDate(DateTime.parse(reunionInfo.dateReunion.toString())) : 'Date non disponible'}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Statut : ${reunionInfo.statut ?? 'Statut inconnu'}',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: reunionInfo.statut == 'resolu' ? Colors.green : Colors.red,
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
              'Debut : ${reunionInfo.heureDebut.hour ?? 'Non spécifiée'}:${reunionInfo.heureDebut.minute ?? 'Non spécifiée'} -'
                  ' Fin : ${reunionInfo.heureFin.hour ?? 'Non spécifiée'}:${reunionInfo.heureFin.minute ?? 'Non spécifiée'}',
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
      ],
    );
  }
}
