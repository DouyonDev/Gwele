import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialiser FCM et demander les permissions si nécessaire
  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
  }

  // Envoyer la notification
  Future<void> sendNotification(String title, String body, List<String> userTokens) async {
    for (String token in userTokens) {
      await _sendToUser(token, title, body);
    }
  }

  // Méthode privée pour envoyer une notification à un utilisateur via l'API FCM
  Future<void> _sendToUser(String token, String title, String body) async {
    try {
      const String serverToken = 'BJrdGqugU_00AC1_Tq3Jv_ki4Rkk9Mv0ZZ1n9CGoFX2tHP5KgCab3sTOVMG5DHBdG-8VmqAJvlSY04WPG1kT7co'; // Remplace par ta clé serveur FCM
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      };

      final notification = {
        'to': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'priority': 'high',
      };

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: jsonEncode(notification),
      );

      if (response.statusCode == 200) {
        print('Notification envoyée avec succès à $token');
      } else {
        print('Erreur lors de l\'envoi de la notification: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }

  Future<List<String>> getNotificationTokens(List<String> participants) async {
    List<String> tokens = [];

    try {
      for (String participantId in participants) {
        // Récupérer le token FCM de l'utilisateur à partir de Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('utilisateurs').doc(participantId).get();

        if (userDoc.exists && userDoc.data() != null) {
          // Vérifie si le token existe et l'ajoute à la liste
          String? token = userDoc['notificationToken'];
          if (token != null) {
            tokens.add(token);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des tokens: $e');
    }

    return tokens;
  }
}
