import 'package:flutter/material.dart';
import 'package:gwele/Models/Commentaire.dart';
import 'package:gwele/Screens/Widgets/user_info_widget.dart';
import 'package:gwele/Services/UtilsService.dart';

class AffichageCommentaire extends StatelessWidget {
  final Commentaire commentaireData;

  AffichageCommentaire({required this.commentaireData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailEquipe(equipeInfo: commentaireData,),
          ),
        );*/
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFFFAF0E6), // Couleur de fond
            borderRadius: BorderRadius.circular(20), // Bordure arrondie
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Décalage de l'ombre
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserInfoWidget(userId : commentaireData.auteurId, size: 20,),
                    Text(
                      UtilsService().formatDate(commentaireData.dateCommentaire),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ]
                ),
                Text(
                  commentaireData.ordreDuJour!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  commentaireData.contenu,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

              ]

            ),
          ),
        ),
      ),
    );
  }
}
