import 'package:flutter/material.dart';

import '../../Colors.dart';

class AppBarListPage extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const AppBarListPage({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor, // Ajoutez vos propres couleurs ici
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: onButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Ajoutez vos propres couleurs ici
            minimumSize: const Size(10, 20), // Ajustez ici la longueur et la largeur du bouton
            textStyle: const TextStyle(
              fontSize: 10, // Ajustez ici la taille de la police
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Pour arrondir les coins si nécessaire
            ),
          ),
          child: Text(
              buttonText,
            style: const TextStyle(
              color: thirdColor,
            ),
          ),
        ),
      ],
    );
  }

  // Ceci est requis pour AppBar pour définir sa hauteur
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
