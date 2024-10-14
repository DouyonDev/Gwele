import 'package:flutter/material.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Services/UtilisateurService.dart';

class UserInfoWidget extends StatelessWidget {
  final String userId;

  const UserInfoWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Utilisateur?>(
      future: UtilisateurService().utilisateurParId(userId), // Appel au service
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Affichage du loader pendant l'attente des données
        }

        if (snapshot.hasError) {
          return const Text('Erreur lors de la récupération des données'); // Gestion des erreurs
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Utilisateur non trouvé'); // Si l'utilisateur n'existe pas
        }

        Utilisateur userData = snapshot.data!; // Récupération des données utilisateur
        String firstName = userData.prenom ?? 'Inconnu';
        String lastName = userData.nom ?? 'Inconnu';
        String avatarUrl = userData.imageUrl ?? ''; // URL de l'avatar (peut être vide)

        return Row(
          children: [
            // Avatar de l'utilisateur
            CircleAvatar(
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl) as ImageProvider
                  : const AssetImage('assets/images/boy.png'), // Avatar par défaut si l'URL est vide
              radius: 10,
            ),
            const SizedBox(width: 10),
            // Prénom et nom de l'utilisateur
            Text(
              firstName,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              lastName,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      },
    );
  }
}
