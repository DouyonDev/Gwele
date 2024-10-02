import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Screens/password_change.dart';

import '../Colors.dart';
import '../Services/AuthService.dart';
import '../Services/BoutonService.dart';
import 'Widgets/options_compte.dart';
import 'aide_support.dart';
import 'apropos.dart';
import 'modification_compte.dart';

class Profil extends StatelessWidget {

  final AuthService authService = AuthService();
  final BoutonService boutonService = BoutonService();


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    //print(user?.email);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Vous devez être connecté pour voir votre profil.')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor,));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Impossible de récupérer les informations utilisateur.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                const SizedBox(height: 50),
                // Bloc avec photo de profil, nom, prénom, rôle et bouton crayon
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: thirdColor,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Position de l'ombre
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundImage: data['imageUrl'] != null
                            ? NetworkImage(data['imageUrl'])  // Utiliser NetworkImage pour les images depuis Firebase Storage
                            : const AssetImage('assets/images/boy.png') as ImageProvider,
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['prenom']} ${data['nom']}', // Affichage du prénom et nom
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              data['role'] ?? 'Rôle inconnu', // Affichage du rôle
                              style: const TextStyle(
                                fontSize: 10,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: primaryColor),
                        onPressed: () {
                          // Action lors du clic sur le bouton crayon
                          // Naviguer vers la page de modification du profil
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ModificationCompte()
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                // Liste des options
                Expanded(
                  child: ListView(
                    children: [
                      OptionsCompte(
                        //context,
                        icon: Icons.person,
                        title: 'Compte',
                        onTap: () {
                          // Action lors du clic sur "Compte"
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ModificationCompte()
                          ));
                        },
                      ),
                      OptionsCompte(
                        //context,
                        icon: Icons.help,
                        title: 'Aide et support',
                        onTap: () {
                          // Action lors du clic sur "Aide et support"
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AideSupport(),
                          ));
                        },
                      ),
                      OptionsCompte(
                        //context,
                        icon: Icons.security,
                        title: 'Sécurité',
                        onTap: () {
                          // Action lors du clic sur "Sécurité"
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PasswordChange(),
                          ));
                        },
                      ),
                      OptionsCompte(
                        //context,
                        icon: Icons.info,
                        title: 'À propos',
                        onTap: () {
                          // Action lors du clic sur "À propos"
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Apropos(),
                          ));
                        },
                      ),
                      OptionsCompte(
                        //context,
                        icon: Icons.logout,
                        title: 'Déconnexion',
                        onTap: () {
                          // Action lors du clic sur "Déconnexion"
                          boutonService.boutonDeconnexion(context); // Afficher la boîte de dialogue de confirmation
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}




