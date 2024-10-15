import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Tache.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/ReunionService.dart';

import 'confirmation_dialog.dart';


class BottomBlockTache extends StatefulWidget {
  final Tache tacheInfo;

  const BottomBlockTache({Key? key, required this.tacheInfo}) : super(key: key);

  @override
  _BottomBlockTacheState createState() => _BottomBlockTacheState();
}

class _BottomBlockTacheState extends State<BottomBlockTache> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = AuthService().idUtilisateurConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildUploadButton(),
        if (widget.tacheInfo.assigneA == userId) _buildLeadButtons(),
        _buildCommentButton(),
        _buildActionButtons(),
      ],
    );
  }

  // Bouton pour envoyer un document
  Widget _buildUploadButton() {
    return widget.tacheInfo.statut != "Archivee"
        ? Tooltip(
      message: "Envoyer un document",
      child: IconButton(
        icon: const Icon(Icons.upload_file, color: primaryColor),
        onPressed: () => _uploadDocument(),
      ),
    )
        : const SizedBox.shrink();
  }

  Future<void> _uploadDocument() async {
    File? fichierSelectionne = await FichiersService().selectionnerFichier();
    if (fichierSelectionne != null) {
      String fileName = fichierSelectionne.path.split('/').last;
      String downloadUrl = await FichiersService().uploaderFichierReunion(fichierSelectionne, fileName);
      setState(() {});
      print('Fichier uploadé avec succès : $downloadUrl');
    } else {
      print('Aucun fichier sélectionné.');
    }
  }

  // Boutons pour le lead (modifier, supprimer)
  Widget _buildLeadButtons() {
    return Row(
      children: [
        Tooltip(
          message: "Modifier la réunion",
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              if (widget.tacheInfo.statut != "Terminee") {/*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifierReunion(reunion: widget.tacheInfo),
                  ),
                );*/
              }
            },
          ),
        ),
        if (widget.tacheInfo.statut == "En attente")
          Tooltip(
            message: "Supprimer la réunion",
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(context: context,
                  builder: (BuildContext context) {
                  return ConfirmationDialog(
                      title: 'Suppression de la réunion',
                      content: 'Voulez-vous supprimer cette réunion ?',
                      onConfirm: () {
                        ReunionService().supprimerReunion(widget.tacheInfo.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reunion supprimé')),
                        );
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      }
                      );
                },
                );
              },
            ),
          ),
      ],
    );
  }


  // Bouton pour commenter
  Widget _buildCommentButton() {
    return Tooltip(
      message: "Voir les commentaires",
      child: IconButton(
        icon: const Icon(Icons.comment, color: Colors.green),
        onPressed: () {/*
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentairesReunion(reunion: widget.tacheInfo),
            ),
          );*/
        },
      ),
    );
  }

  // Boutons d'action (démarrer, arrêter, générer)
  Widget _buildActionButtons() {
    if (widget.tacheInfo.statut == "En attente" && widget.tacheInfo.assigneA == userId) {
      return Tooltip(
        message: "Démarrer la réunion",
        child: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green),
          onPressed: () {
            // Logique pour démarrer la réunion
            print('Réunion démarrée');
          },
        ),
      );
    } else if (widget.tacheInfo.statut == "En cours" && widget.tacheInfo.assigneA == userId) {
      return Row(
        children: [
          Tooltip(
            message: "Arrêter la réunion",
            child: IconButton(
              icon: const Icon(Icons.stop, color: Colors.red),
              onPressed: () {
                // Logique pour arrêter la réunion
                print('Réunion arrêtée');
              },
            ),
          ),
          Tooltip(
            message: "Générer le rapport",
            child: IconButton(
              icon: const Icon(Icons.file_download, color: Colors.blue),
              onPressed: () {
                // Logique pour générer le rapport
                print('Rapport généré');
              },
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}