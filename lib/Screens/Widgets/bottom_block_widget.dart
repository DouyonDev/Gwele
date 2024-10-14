import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Screens/Lead/ModifierReunion.dart'; // Importez la page des commentaires
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/FichiersService.dart';

class BottomBlockReunion extends StatefulWidget {
  final Reunion reunionInfo;

  const BottomBlockReunion({Key? key, required this.reunionInfo}) : super(key: key);

  @override
  _BottomBlockReunionState createState() => _BottomBlockReunionState();
}

class _BottomBlockReunionState extends State<BottomBlockReunion> {
  @override
  Widget build(BuildContext context) {
    String? userId = AuthService().idUtilisateurConnect();
    return Row(
      children: [
        if (widget.reunionInfo.statut != "Archivee")
          Tooltip(
            message: "Envoyer un document",
            child: IconButton(
              icon: const Icon(Icons.upload_file, color: primaryColor),
              onPressed: () async {
                File? fichierSelectionne = await FichiersService().selectionnerFichier();
                if (fichierSelectionne != null) {
                  String fileName = fichierSelectionne.path.split('/').last;
                  String downloadUrl = await FichiersService().uploaderFichierReunion(fichierSelectionne, fileName);
                  setState(() {});
                  print('Fichier uploadé avec succès : $downloadUrl');
                } else {
                  print('Aucun fichier sélectionné.');
                }
              },
            ),
          ),
        if (widget.reunionInfo.lead == userId)
          Row(
            children: [
              // Modifier réunion
              Tooltip(
                message: "Modifier la réunion",
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModifierReunion(reunion: widget.reunionInfo),
                      ),
                    );
                  },
                ),
              ),
              // Ajouter l'icône pour commenter la réunion
              Tooltip(
                message: "Voir les commentaires",
                child: IconButton(
                  icon: const Icon(Icons.comment, color: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentairesReunion(reunion: widget.reunionInfo), // Naviguer vers la page des commentaires
                      ),
                    );
                  },
                ),
              ),
              // Autres boutons (commencer, terminer, etc.)
            ],
          ),
      ],
    );
  }
}
