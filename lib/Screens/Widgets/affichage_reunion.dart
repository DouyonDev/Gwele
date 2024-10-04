import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';

class AffichageReunion extends StatelessWidget {
  final Map<String, dynamic> reunionData;

  AffichageReunion({required this.reunionData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetail(reunionData: reunionData),
          ),
        );*/
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reunionData['titre'] ?? 'Sans titre',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                reunionData['dateReunion'] ?? 'date non renseignée',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(),
              Text(
                reunionData['ordreDujour'] ?? 'Pas d\'ordre du jour !!!',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date Ajout: ${reunionData['created_at'] != null ? (reunionData['created_at'] as Timestamp).toDate().toLocal().toString().split(' ')[0] : 'Date non disponible'}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Statut : ${reunionData['statut'] ?? 'Statut inconnu'}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: reunionData['statut'] == 'resolu'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
