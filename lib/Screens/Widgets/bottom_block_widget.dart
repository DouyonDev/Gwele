import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Lead/ModifierReunion.dart';
import 'package:gwele/Screens/Widgets/affichage_boutons_selection_participant.dart';
import 'package:gwele/Screens/Widgets/confirmation_dialog.dart';
import 'package:gwele/Screens/Widgets/message_modale.dart';
import 'package:gwele/Screens/commentaires_reunion.dart';
import 'package:gwele/Services/AuthService.dart';
import 'package:gwele/Services/FichiersService.dart';
import 'package:gwele/Services/ListeParticipantsService.dart';
import 'package:gwele/Services/ReunionService.dart';
import 'package:gwele/Services/UtilisateurService.dart';
import 'package:gwele/Services/push_notification_service.dart';


class BottomBlockReunion extends StatefulWidget {
  final Reunion reunionInfo;

  const BottomBlockReunion({Key? key, required this.reunionInfo}) : super(key: key);

  @override
  _BottomBlockReunionState createState() => _BottomBlockReunionState();
}

class _BottomBlockReunionState extends State<BottomBlockReunion> {
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
        if (widget.reunionInfo.lead == userId) _buildLeadButtons(),
        _buildCommentButton(),
        _buildActionButtons(),
      ],
    );
  }

  // Bouton pour envoyer un document
  Widget _buildUploadButton() {
    return widget.reunionInfo.statut != "Archivee"
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
              if (widget.reunionInfo.statut != "Terminee") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifierReunion(reunion: widget.reunionInfo),
                  ),
                );
              }
            },
          ),
        ),
        if (widget.reunionInfo.statut == "En attente")
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
                        ReunionService().supprimerReunion(widget.reunionInfo.id);
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentairesReunion(reunion: widget.reunionInfo),
            ),
          );
        },
      ),
    );
  }

  // Boutons d'action (démarrer, arrêter, générer)
  Widget _buildActionButtons() {
    if (widget.reunionInfo.statut == "En attente" && widget.reunionInfo.lead == userId) {
      return AffichageBoutonSelectionParticipant(
        title: 'Séléctionner le rapporteur de la réunion',
        buttonText: 'Démarrer la réunion',
        onParticipantSelected: onParticipantSelected,
        setState: () => setState(() {}),
        fetchParticipants: () => ListeParticipantsService().listeParticipantsPourReunion(widget.reunionInfo.id),
      );
    } else if (widget.reunionInfo.statut == "En cours" && widget.reunionInfo.lead == userId) {
      return Row(
        children: [
          Tooltip(
            message: "Arrêter la réunion",
            child: IconButton(
              icon: const Icon(Icons.stop, color: Colors.red),
              onPressed: () {
                showDialog(context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                        title: "Démande d'arrêt de la réunion",
                        content: "Voulez-vous arrêter cette réunion ?",
                        onConfirm: () {
                          widget.reunionInfo.statut = "Terminer";
                          ReunionService().mettreAJourReunion(widget.reunionInfo);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          setState(() {
                            this.widget.reunionInfo.statut = "Terminer";
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reunion arrêtée')),
                          );
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        });
                  },
                );
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

  void onParticipantSelected(String participantID) async {
    try {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(participantID);
      if (utilisateur != null) {
        widget.reunionInfo.rapporteur = participantID;

        widget.reunionInfo.statut = "En cours";
        ReunionService().mettreAJourReunion(widget.reunionInfo);
        print(widget.reunionInfo.statut);
        Utilisateur? rapporteurInfo = await UtilisateurService().utilisateurParId(participantID);
        await PushNotificationService.sendNotification(
          title: widget.reunionInfo.titre,
          body: "Vous avez été choisie comme rapporteur de la réunion sur : ${widget.reunionInfo.titre}",
          token: rapporteurInfo!.notificationToken, // Assurez-vous que chaque participant a un tokenFirebase
          contextType: "reunion",
          contextData: widget.reunionInfo.id, // Utilisation de l'ID de la réunion comme contextData
        );

        // Boucle pour envoyer une notification à chaque participant
        for (var participant in widget.reunionInfo.participants) {
          Utilisateur? participantInfo = await UtilisateurService().utilisateurParId(participant);
          // Boucle pour envoyer une notification à chaque participant
          await PushNotificationService.sendNotification(
            title: "Démarrage de la réunion",
            body: "La réunion sur ${widget.reunionInfo.titre} est demarrée",
            token: participantInfo!.notificationToken, // Assurez-vous que chaque participant a un tokenFirebase
            contextType: "reunion",
            contextData: widget.reunionInfo.id, // Utilisation de l'ID de la réunion comme contextData
          );
        }
        showDialog(context: context,
          builder: (BuildContext context) {
            return const MessageModale(
                title: "Démarrage de la réunion",
                content: "Votre réunion est demarrée. Les utilisateurs seront notifiés.",);
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' ${utilisateur.prenom} ${utilisateur.nom} est le rapporteur de la réunion')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection du rapporteur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération du rapporteur')),
      );
    }
  }
}