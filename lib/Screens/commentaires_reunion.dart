import 'package:flutter/material.dart';
import 'package:gwele/Models/Reunion.dart';
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
  List<Map<String, String>> _commentaires = []; // Liste des commentaires à récupérer depuis la base

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

  // Récupérer la liste des commentaires depuis la base
  void LesCommentaires() async {
    List<Map<String, String>> commentaires = await CommentairesService().getCommentaires(widget.reunion.id);
    setState(() {
      _commentaires = commentaires;
    });
  }

  // Fonction pour ajouter un commentaire
  void _ajouterCommentaire() {
    if (_selectedOrdreDuJour != null && _commentaireController.text.isNotEmpty) {
      CommentairesService().ajouterCommentaire(
        reunionId: widget.reunion.id,
        ordreDuJour: _selectedOrdreDuJour!,
        commentaire: _commentaireController.text,
      );
      _commentaireController.clear();
      _fetchCommentaires(); // Actualiser la liste des commentaires
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires sur la réunion'),
      ),
      body: Column(
        children: [
          // Liste des commentaires
          Expanded(
            child: ListView.builder(
              itemCount: _commentaires.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_commentaires[index]['ordreDuJour'] ?? ''),
                  subtitle: Text(_commentaires[index]['commentaire'] ?? ''),
                );
              },
            ),
          ),
          const Divider(),
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
                  hint: const Text("Sélectionner l'ordre du jour"),
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
