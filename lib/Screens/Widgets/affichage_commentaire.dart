import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Commentaire.dart';

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
                commentaireData.contenu ?? 'Sans titre',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
