import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Equipe.dart';
import 'package:gwele/Models/Utilisateur.dart';
import 'package:gwele/Screens/Manager/ajout_Membre.dart';
import 'package:gwele/Services/EquipeService.dart';
import 'package:gwele/Services/UtilisateurService.dart';

import '../Widgets/affichage_boutons_selection_participant.dart';

class DetailEquipe extends StatefulWidget {
  final Equipe equipeInfo;

  const DetailEquipe({Key? key, required this.equipeInfo}) : super(key: key);

  @override
  _DetailEquipeState createState() => _DetailEquipeState();
}

class _DetailEquipeState extends State<DetailEquipe> {
  Future<List<Utilisateur>>? _membresFuture;
  Utilisateur? leader;
  Utilisateur? second;
  Future<Utilisateur>? _futureLead;
  Future<Utilisateur>? _futureSecond;

  @override
  void initState() {
    super.initState();
    getLeadSecond();
    // Récupère les informations des membres dès le début
    _membresFuture = recupererMembres(widget.equipeInfo.membres);
  }

  // Récupérer les informations du leader et du second
  Future<void> getLeadSecond() async {
    // Vérification de leaderId
    if (widget.equipeInfo.leaderId != null && widget.equipeInfo.leaderId!.isNotEmpty) {
      try {
        final leaderData = await UtilisateurService().utilisateurParId(widget.equipeInfo.leaderId);
        setState(() {
          leader = leaderData; // Assigner l'utilisateur récupéré
        });
      } catch (e) {
        print("Erreur lors de la récupération du leader: $e");
        setState(() {
          leader = null; // Assigner null si une erreur survient
        });
      }
    } else {
      print("Leader ID est vide ou null");
      setState(() {
        leader = null; // Assigner null si leaderId est vide
      });
    }

    // Vérification de secondId
    if (widget.equipeInfo.secondId != null && widget.equipeInfo.secondId!.isNotEmpty) {
      try {
        final secondData = await UtilisateurService().utilisateurParId(widget.equipeInfo.secondId!);
        setState(() {
          second = secondData; // Assigner l'utilisateur récupéré
        });
      } catch (e) {
        print("Erreur lors de la récupération du second: $e");
        setState(() {
          second = null; // Assigner null si une erreur survient
        });
      }
    } else {
      print("Second ID est vide ou null");
      setState(() {
        second = null; // Assigner null si secondId est vide
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'Détails de l\'équipe',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded( // Utiliser Expanded pour faire occuper l'espace restant
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Premier Bloc: Titre, Date, Statut, Heure, Salle
                    blocStyle(_buildFirstBlock()),
                    const SizedBox(height: 20),
                    // Quatrième Bloc: Description de l'équipe
                    blocStyle(_buildLeadSecondBlock()),
                    const SizedBox(height: 20),
                    // Deuxième Bloc: Liste des documents
                    blocStyle(_buildMembresBlock()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premier Bloc: Titre, Date, Statut, Heure, Salle
  Widget _buildFirstBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.equipeInfo.nom ?? 'Sans titre',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date de création : ${widget.equipeInfo.dateCreation?.day}/'
                  '${widget.equipeInfo.dateCreation?.month}/'
                  '${widget.equipeInfo.dateCreation?.year}',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  // Bloc: Description de l'équipe
  Widget _buildLeadSecondBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Leader :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const CircleAvatar(
          radius: 40.0,
          backgroundImage: AssetImage('assets/images/boy.png') as ImageProvider,
          ),
          title: Text(
          '${leader?.prenom} ${leader?.nom}',
          style: const TextStyle(fontSize: 16.0),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Adjoint :',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
          ListTile(
            leading: const CircleAvatar(
              radius: 40.0,
              backgroundImage: AssetImage('assets/images/boy.png') as ImageProvider,
            ),
            title: Text(
              '${second?.prenom} ${second?.nom}',
              style: const TextStyle(fontSize: 16.0),
            ),
          )
      ],
    );
  }

  // Bloc: Liste des membres de l'équipe
  Widget _buildMembresBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Les membres :',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AjoutMembre(equipe: widget.equipeInfo)
                  )
              );
            }, child: Text("Ajouter"))
            /*AffichageBoutonSelectionParticipant(
              title: 'Choisissez l\'adjoint du groupe',
              buttonText: 'Ajouter',
              onParticipantSelected: onParticipantSelected,
              setState: () => setState(() {}), // Appel à setState dans le parent
              fetchParticipants: fetchParticipants,
            ),*/
          ],
        ),
        const SizedBox(height: 10),

        // FutureBuilder pour charger les membres
        FutureBuilder<List<Utilisateur>>(
          future: _membresFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Affiche un indicateur de chargement
            } else if (snapshot.hasError) {
              return const Text('Erreur lors du chargement des membres');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Aucun membre trouvé');
            } else {
              // Affiche la liste des membres
              return Column(
                children: snapshot.data!.map((membre) {
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 40.0,
                      backgroundImage: AssetImage('assets/images/boy.png') as ImageProvider,
                    ),
                    title: Text(
                      '${membre.prenom} ${membre.nom}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  // Bloc Style
  Widget blocStyle(Widget bloc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: bloc,
      ),
    );
  }

  // Fonction pour récupérer les membres
  Future<List<Utilisateur>> recupererMembres(List<String> membresIds) async {
    List<Utilisateur> membres = [];

    for (String id in membresIds) {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(id);
      if (utilisateur != null) {
        membres.add(utilisateur);
      }
    }

    return membres;
  }

  Future<QuerySnapshot> fetchParticipants() async {
    return await FirebaseFirestore.instance.collection('utilisateurs').get();
  }

  // Fonction pour ajouter un membre à la liste des participants
  void onParticipantSelected(String membreID) async {
    widget.equipeInfo.membres.add(membreID);
    EquipeService().mettreAJourEquipe(widget.equipeInfo);
    try {
      Utilisateur? utilisateur = await UtilisateurService().utilisateurParId(membreID);
      if (utilisateur != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('membre sélectionné: ${utilisateur.prenom} ${utilisateur.nom}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection du membre: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération du membre')),
      );
    }
  }
}
