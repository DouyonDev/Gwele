import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Screens/utils.dart';
import 'package:gwele/Services/BoutonService.dart';

// Classe principale de l'écran de connexion
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

// État de l'écran de connexion
class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = ''; // Variable pour stocker l'email
  String _password = ''; // Variable pour stocker le mot de passe
  bool _obscureText = true; // Contrôle de la visibilité du mot de passe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Couleur de fond de l'écran
      body: Center( // Centrer le contenu horizontalement et verticalement
        child: SingleChildScrollView(
          child: Padding(
            padding: Responsive.isMobile(context)
                ? const EdgeInsets.all(20.0)
                : const EdgeInsets.all(40.0),
            child: Responsive.isMobile(context)
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLogo(), // Méthode pour construire le logo
                const SizedBox(height: 50), // Espace entre le logo et le formulaire
                _buildLoginForm(), // Méthode pour construire le formulaire de connexion
                const SizedBox(height: 30), // Espace après le formulaire
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child: _buildLogo()), // Logo à gauche
                const VerticalDivider( // Ligne de séparation verticale
                  thickness: 1, // Épaisseur de la ligne
                  color: Colors.grey, // Couleur de la ligne
                  width: 40, // Largeur de la zone de séparation
                ),
                Expanded(
                  child: _buildLoginForm(), // Formulaire de connexion à droite
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire le logo
  Widget _buildLogo() {
    return Image.asset(
      "assets/images/logoGwele.png", // Chemin vers l'image du logo
      height: Responsive.isMobile(context) ? 120 : 300, // Hauteur du logo selon le type d'appareil
    );
  }

  // Méthode pour construire le formulaire de connexion
  Widget _buildLoginForm() {
    return Container(
      width: Responsive.isDesktop(context) ? 400 : null, // Limite la largeur pour les écrans de bureau
      child: Column(
        children: <Widget>[
          const Text(
            "Connexion", // Titre du formulaire
            style: TextStyle(
              fontSize: 24,
              color: primaryColor, // Couleur du texte
            ),
          ),
          const SizedBox(height: 50), // Espace entre le titre et les champs de formulaire
          Form(
            key: _formKey, // Associe la clé au formulaire
            child: Column(
              children: <Widget>[
                // Champ pour l'email
                TextFormField(
                  key: const ValueKey('email'), // Clé pour identifier le champ
                  validator: (value) {
                    // Validation de l'email
                    if (value == null || !value.contains('@')) {
                      return 'Veuillez entrer un email valide.'; // Message d'erreur
                    }
                    return null; // Pas d'erreur
                  },
                  keyboardType: TextInputType.emailAddress, // Type de clavier pour email
                  decoration: const InputDecoration(
                    iconColor: secondaryColor, // Couleur de l'icône
                    labelText: 'Votre e-mail', // Texte du label
                    labelStyle: TextStyle(color: secondaryColor), // Style du label
                    prefixIcon: Icon(Icons.mail), // Icône avant le champ
                  ),
                  style: const TextStyle(
                    color: secondaryColor, // Couleur du texte
                    fontSize: 16, // Taille de la police
                  ),
                  onSaved: (value) {
                    _email = value!; // Sauvegarde de l'email
                  },
                ),
                const SizedBox(height: 20), // Espace entre les champs
                // Champ pour le mot de passe
                TextFormField(
                  key: const ValueKey('password'), // Clé pour identifier le champ mot de passe
                  validator: (value) {
                    // Validation du mot de passe
                    if (value == null || value.length < 6) {
                      return 'Le mot de passe doit comporter au moins 6 caractères.'; // Message d'erreur
                    }
                    return null; // Pas d'erreur
                  },
                  obscureText: _obscureText, // Cache le mot de passe si _obscureText est vrai
                  decoration: InputDecoration(
                    labelText: 'Mot de passe', // Texte du label
                    labelStyle: const TextStyle(color: secondaryColor), // Style du label
                    prefixIcon: const Icon(Icons.lock), // Icône avant le champ
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off, // Icône de visibilité
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText; // Inverse la visibilité
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(
                    color: secondaryColor, // Couleur du texte
                    fontSize: 16, // Taille de la police
                  ),
                  onSaved: (value) {
                    _password = value!; // Sauvegarde du mot de passe
                  },
                ),
                const SizedBox(height: 30), // Espace entre les champs et le bouton
                ElevatedButton(
                  onPressed: () {
                    // Action lorsque le bouton est pressé
                    if (_formKey.currentState!.validate()) { // Validation du formulaire
                      _formKey.currentState!.save(); // Sauvegarde des valeurs

                      // Appel au service pour soumettre le formulaire
                      BoutonService().boutonConnexion(
                        _formKey,
                        _email,
                        _password,
                        context,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20), // Taille du texte du bouton
                    foregroundColor: Colors.white, // Couleur du texte
                    backgroundColor: primaryColor, // Couleur de fond
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Padding du bouton
                  ),
                  child: const Text("Se connecter"), // Texte du bouton
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
