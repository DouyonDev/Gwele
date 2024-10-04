import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/OrdreDuJour.dart'; // Assurez-vous d'avoir un modèle OrdreDuJour défini

class OrdreDuJourService {
  final CollectionReference ordreDuJourCollection =
  FirebaseFirestore.instance.collection('ordresDuJour');

  // Fonction pour ajouter un ordre du jour
  Future<void> ajouterOrdreDuJour(OrdreDuJour ordreDuJour, BuildContext context) async {
    try {
      // Ajout de l'ordre du jour dans la collection Firestore
      DocumentReference docRef = await ordreDuJourCollection.add(ordreDuJour.toMap());

      // Mise à jour de l'objet OrdreDuJour avec l'ID généré
      ordreDuJour.id = docRef.id; // Si vous avez un champ 'id' dans votre modèle
      print('Ordre du jour ajouté avec succès avec l\'ID: ${ordreDuJour.id}');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'ordre du jour: $e');
      throw e; // Relance l'erreur pour être gérée au niveau supérieur
    }
  }

  // Récupérer une liste d'ordres du jour
  Stream<List<OrdreDuJour>> listeOrdresDuJour() {
    try {
      return ordreDuJourCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return OrdreDuJour(
            id: doc.id,
            titre: data['titre'] ?? 'Sans titre',
            description: data['description'] ?? 'Pas de description',
            statut: data['statut'] ?? 'En attente',
            decisions: data['decisions'] ?? '', // Par défaut, vide
          );
        }).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des ordres du jour: $e');
      rethrow;
    }
  }

  // Mise à jour d'un ordre du jour
  Future<void> mettreAJourOrdreDuJour(OrdreDuJour ordreDuJour) async {
    try {
      await ordreDuJourCollection.doc(ordreDuJour.id).update({
        'titre': ordreDuJour.titre,
        'description': ordreDuJour.description,
        'statut': ordreDuJour.statut,
        'decisions': ordreDuJour.decisions,
      });
      print('Ordre du jour mis à jour avec succès: ${ordreDuJour.id}');
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'ordre du jour: $e');
      throw e;
    }
  }

  // Suppression d'un ordre du jour
  Future<void> supprimerOrdreDuJour(String id) async {
    try {
      await ordreDuJourCollection.doc(id).delete();
      print('Ordre du jour supprimé avec succès: $id');
    } catch (e) {
      print('Erreur lors de la suppression de l\'ordre du jour: $e');
      throw e;
    }
  }
}
