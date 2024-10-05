import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Services/UtilsService.dart';

import '../../Models/Offre.dart';
import '../details_offres.dart';

class AffichageOffre extends StatelessWidget {
  final Offre offreData;

  AffichageOffre({required this.offreData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailOffre(offreInfo: offreData,),
          ),
        );
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
                offreData.titre ?? 'Sans titre',
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
                    'Date : ${UtilsService().formatDate(offreData.dateLimite) != null ? (UtilsService().formatDate(offreData.dateLimite)) : 'Date non disponible'}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    offreData.statut ?? 'Statut inconnu',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: offreData.statut == 'resolu'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Text(
                    offreData.isExpired.toString(),
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
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
