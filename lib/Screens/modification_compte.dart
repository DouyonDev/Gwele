import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import de Firebase Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Colors.dart';
import 'Widgets/message_modale.dart';

class ModificationCompte extends StatefulWidget {
  @override
  _ModificationCompteState createState() => _ModificationCompteState();
}

class _ModificationCompteState extends State<ModificationCompte> {
  String? _imagePath;
  late TextEditingController _prenomController;
  late TextEditingController _nomController;
  String? _imageUrl; // Stocker l'URL de l'image
  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs de texte avec des valeurs vides
    _prenomController = TextEditingController();
    _nomController = TextEditingController();
    // Charger les données utilisateur
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).get();
      setState(() {
        _prenomController.text = userData['prenom'] ?? '';
        _nomController.text = userData['nom'] ?? '';
        _imageUrl = userData.data()?['imageUrl'] ?? ''; // Si 'imageUrl' n'existe pas, assigner une chaîne vide
        _isLoading = false; // Fin du chargement
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      await _uploadImage(File(image.path)); // Uploader l'image sélectionnée
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Créer une référence dans Firebase Storage pour l'image
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(user.uid + '.jpg');

        // Uploader l'image
        await ref.putFile(image);

        // Récupérer l'URL de l'image uploadée
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          _imageUrl = downloadUrl;
        });

        // Mettre à jour l'URL de l'image dans Firestore
        await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).update({
          'imageUrl': _imageUrl,
        });
      }
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      // Affichage d'un indicateur de chargement pendant le chargement des données
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
        title: const Text('Modifier le profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bloc pour la photo de profil
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage: _imagePath != null
                            ? FileImage(File(_imagePath!))
                            : (_imageUrl != null
                            ? NetworkImage(_imageUrl!)
                            : const AssetImage('assets/images/boy.png')) as ImageProvider,
                      ),
                      Positioned(
                        bottom: -4,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: primaryColor),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${_prenomController.text} ${_nomController.text}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50.0),
            // Bloc pour la modification des informations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: ListView(
                  children: [
                    TextField(
                      controller: _prenomController,
                      style: const TextStyle(
                        color: secondaryColor,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(
                          color: Colors.grey,
                        )
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: _nomController,
                      style: const TextStyle(
                        color: secondaryColor,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                          )
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Espacement personnalisé
                      ),
                      onPressed: () async {
                        if (_imagePath != null) {
                          // Si une nouvelle image a été sélectionnée, uploader l'image
                          await _uploadImage(File(_imagePath!));
                        }

                        // Enregistrer les modifications dans Firestore
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).update({
                            'prenom': _prenomController.text,
                            'nom': _nomController.text,
                            'imageUrl': _imageUrl, // Mettre à jour l'URL de l'image
                          });
                        }

                        // Afficher la boîte de dialogue modale de succès
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const MessageModale(
                              title: "Success",
                              content: "Modification réussie",
                            );
                          },
                        );
                        // Retour à la page précédente
                        //Navigator.of(context).pop();
                      },
                      child: const Text('Modifier'),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
