import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Commentaire.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Screens/Widgets/affichage_commentaire.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/CommentaireService.dart';
import 'package:gwele/Services/ReunionService.dart';

class CommentairesReunion extends StatefulWidget {
  final Reunion reunion;

  const CommentairesReunion({Key? key, required this.reunion}) : super(key: key);

  @override
  _CommentairesReunionState createState() => _CommentairesReunionState();
}

class _CommentairesReunionState extends State<CommentairesReunion> {
  final TextEditingController _commentaireController = TextEditingController();
  String? _selectedOrdreDuJour;
  List<String> _ordresDuJour = [];
  List<Commentaire> _commentaires = []; // Liste des commentaires à récupérer depuis la base

  @override
  void initState() {
    super.initState();
    LesOrdresDuJour();
    LesCommentaires();
  }

  // Récupérer la liste des ordres du jour depuis la base
  void LesOrdresDuJour() async {
    List<String> ordres = await ReunionService().obtenirOrdresDuJour(widget.reunion.id);
    setState(() {
      _ordresDuJour = ordres;
    });
  }

  void LesCommentaires() {
    // On écoute les changements en temps réel sur les commentaires de la réunion
    CommentaireService().obtenirCommentaires(widget.reunion.id).listen((commentaires) {
      setState(() {
        _commentaires = commentaires;
      });
    });
  }


  // Fonction pour ajouter un commentaire
  Future<void> _ajouterCommentaire()  async {
    String? auteurId = await AuthService().idUtilisateurConnecte();
    if (_commentaireController.text.isNotEmpty) {
      Commentaire commentaire = Commentaire(
          id: '',
          reunionId: widget.reunion.id,
          auteurId: auteurId!,
          ordreDuJour: _selectedOrdreDuJour,
          contenu: _commentaireController.text,
          dateCommentaire: DateTime.now()
      );
      CommentaireService().ajouterCommentaire(commentaire);
      _commentaireController.clear();
      LesCommentaires(); // Actualiser la liste des commentaires
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Commentaires sur la réunion'),
      ),
      body: Column(
        children: [
          // Liste des commentaires
          Expanded(
            child: StreamBuilder<List<Commentaire>>(
              stream: CommentaireService().obtenirCommentaires(widget.reunion.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor,));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                        'Erreur lors de la récupération des commentaires.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                        'Aucun commentaire trouvé.',
                        style: TextStyle(
                          color: secondaryColor,
                        ),
                      )
                  );
                }

                return ListView(
                  children: snapshot.data!.map((commentaire) {
                    // Ici, snapshot.data est déjà une liste de Commentaire
                    return AffichageCommentaire(commentaireData: commentaire); // Passe directement l'objet Commentaire
                  }).toList(),
                );



              },
            ),
          ),
          // Section pour ajouter un commentaire
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Liste déroulante pour sélectionner l'ordre du jour
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedOrdreDuJour,
                  hint: const Text("Sélectionner l'ordre du jour (facultatif)"),
                  items: _ordresDuJour.map((ordre) {
                    return DropdownMenuItem<String>(
                      value: ordre,
                      child: Text(ordre),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedOrdreDuJour = val;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                // Champ de saisie du commentaire
                TextField(
                  controller: _commentaireController,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8.0),
                // Bouton pour soumettre le commentaire
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: _ajouterCommentaire,
                  child: const Text('Envoyer le commentaire'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
