import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Equipe.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Services/BoutonService.dart';


class AjoutMembre extends StatefulWidget {

  Equipe equipe;
  @override
  AjoutMembreState createState() => AjoutMembreState();

  AjoutMembre({Key? key, required this.equipe}) : super(key: key);
}

class AjoutMembreState extends State<AjoutMembre> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _prenom = '';
  String _nom = '';
  String _email = '';

  final FirebaseAuth auth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logoGwele.png", // Chemin vers le logo
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                "Ajout d'un membre d'équipe",
                style: TextStyle(
                  fontSize: 24,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      key: const ValueKey('prenom'),
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _prenom = value!;
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('nom'),
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _nom = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('email'),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Veuillez entrer un email valide.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        Utilisateur membre = Utilisateur(
                          id: '',
                          nom: _nom,
                          prenom: _prenom,
                          role: 'MEMBRE',
                          email: _email,
                          imageUrl: '',
                          userMere: '',
                          notificationToken: '',
                          tachesAssignees: [],
                          reunions: [], // L'ID sera généré automatiquement par Firestore
                        );
                        BoutonService().boutonAjouterMembre(_formKey,context,membre,widget.equipe);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: primaryColor,
                      ),
                      child: const Text(
                        "Enregistrer",
                        style: TextStyle(color: thirdColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
