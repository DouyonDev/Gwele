import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Models/OrdreDuJour.dart';

class OrdreDuJourService {
  final CollectionReference ordreDuJourCollection =
  FirebaseFirestore.instance.collection('ordresDuJour');

  // Fonction pour ajouter un ordre du jour
  Future<String> ajouterOrdreDuJour(OrdreDuJour ordreDuJour, BuildContext context) async {
    try {
      // Ajout de l'ordre du jour dans Firestore
      DocumentReference docRef = await ordreDuJourCollection.add(ordreDuJour.toMap());

      // Mise à jour de l'objet avec l'ID généré
      ordreDuJour.id = docRef.id;

      print('Ordre du jour ajouté avec succès avec l\'ID: ${ordreDuJour.id}');
      return ordreDuJour.id; // Retourner l'ID généré
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'ordre du jour: $e');
      throw e;
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
            decisionsIds: List<String>.from(data['decisions'] ?? []), // Décisions
            duree: data['duree'] != null ? Duration(milliseconds: data['duree']) : Duration.zero, // Durée avec valeur par défaut
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
        'decisions': ordreDuJour.decisionsIds, // Mise à jour des décisions
        'duree': ordreDuJour.duree?.inMilliseconds, // Durée en millisecondes
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

  // Fonction pour récupérer un ordre du jour par ID
  Future<OrdreDuJour?> ordreDuJourParId(String id) async {
    try {
      // Récupérer le document par ID
      DocumentSnapshot docSnapshot = await ordreDuJourCollection.doc(id).get();

      if (docSnapshot.exists) {
        // Extraire les données du document
        final data = docSnapshot.data() as Map<String, dynamic>;

        // Utiliser la méthode fromMap pour créer l'objet OrdreDuJour
        return OrdreDuJour(
          id: id,
          titre: data['titre'],
          description: data['description'],
          statut: data['statut'],
          decisionsIds: List<String>.from(data['decisions'] ?? []),
          duree: data['duree'] != null ? Duration(milliseconds: data['duree']) : Duration.zero, // Durée avec valeur par défaut
        );
      } else {
        print('Ordre du jour avec l\'ID $id n\'existe pas.');
        return null; // Retourne null si le document n'existe pas
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'ordre du jour: $e');
      throw e; // Relance l'erreur pour une gestion éventuelle au niveau supérieur
    }
  }
}
