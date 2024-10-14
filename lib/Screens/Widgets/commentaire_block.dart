import 'package:flutter/material.dart';

class CommentaireBlock extends StatelessWidget {
  final String commentText;

  CommentaireBlock({required this.commentText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 344,
      height: 121,
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
        child: Text(
          commentText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
