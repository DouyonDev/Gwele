import 'package:flutter/material.dart';
import '../../Colors.dart';

class OptionsCompte extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const OptionsCompte({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: secondaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          color: secondaryColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey),
      onTap: onTap,  // Appel de la fonction onTap lors du clic
    );
  }
}
