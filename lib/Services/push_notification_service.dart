import 'dart:convert'; // Import pour jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:provider/provider.dart';

class PushNotificationService {

  // Fonction pour récupérer un token d'accès depuis Firebase
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      // Authentification sécurisée
      "type": "service_account",
      "project_id": "gwele-33e7f",
      "private_key_id": "726131f2207b0a99a6bc6cca15a2ce269cf04a39",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCubmcTMUO7PPIF\nwR+kc+jWFYeazp7iHcLI8w5oE30nRprfcrQx9RTipuf6a/Uk8JtD6OJom3qD/Ba9\ne1lW1vA8Co1ugwr5J01C5/RODXOCJk8tWamKPe0JparG3CFcouEhSu4VdmB7jY36\nDbAfrhSj9FTv16TjIhaC8UcPao5OqBpIShrX07s1JYA1AzzWF5hIXCCZn09YtG6P\nvCZYtLuoJJpLe8n0DKDOkkmOp7z3TPYFuY4xq9JEbyDn4DMB34hXQS+vAg+a5VeQ\nVLCJtElKY7B0hc7VVTjyq7tZPigXdBbxb89aSp+kpJybtKiPiD5Zf38VKBW6uyWI\nXKje9WDhAgMBAAECggEAIi9o7A3/pDZxiEctGGHPBAX8KY7M/KuwfQmFjUgkgwoH\nWDt2rUPG8BSd6io2RSMSiuCdXrr569v/6Oq/u5EsS9gVl87+242kSrSC4LkqJhuz\n8MNdwsYYKofZTFfgAfO6A3hX6MTma9B2Psdn+Q145hkAfHDa09jeaJM4xgCwGyHr\n/aSlmq6xC8hWUoDV/OJNmfZJ6uq0dDgWovSbnxxrZ+95QQSCKQCtr6nOdbKCC1qm\n113FPcbQmpwbGJLdTaTUWeYloYmrt/Sax9upmsF9YbhJv4t61FiYGXOp6XuL64TX\nii9NH7q8IP/+2Rlkw2/LzuJTwk8281j9+r7t0tp7cQKBgQDKl9CbaEPgb/+NAEJz\nGA64CEDLVIim+iM28Z45er0DEfdwyOqCidhC4JEBg6J0CW2BGTDeUayFJff/qnlT\nsWGwE3/ymOHs+WiIEEI3s2M3qqAumNZCs1W4rqv+IC8eNiWP/OnK2McCoWKV1+oh\nxagjO/j/IM1wky/L7B21CL1q2wKBgQDcahBasgwnGSbdYl+DOvWczAcqMZ963gnJ\nIvSTa49jq+JbApJ9wgGHJCYm93fvmVl5MF5XJieswwFrnFD9cNFbmUBAXImWcLBW\ntM1SCstdnmAFFyMF4LbIN6VsHma1jHaRf5axsKKMwQDQSkiyEC67Emai8QarKZ5M\nYYyshrnJ8wKBgQCWukKrDPTLK6iOyC2oIbL5urIyVQ9iY+IFQ9h7XVT4zsow8FqB\ninsKrrdT0BLyj/0Xup1AGrXnTitn3PZtjSBn9uoPnS0huSHLcYVCmcVsqhaI9I8c\niv5w7AvsgxdrO8/Qg9ORZp0R2O5XG5AHVl5U8I69ijMu2WMLLf2gLgN3VwKBgBxg\n85YZ0oK+NEjQv6dv0evMQSfnl7cEG5JwE7lfYejdWpmJLT9P2U6DEv51YlXREroN\nxjfGS9lsiiRGzg6zleELTEB9KaHbBHlFciIcDa8SEx7Uqce59Q62S3AuQd8iJKn7\nGXXrXiJtPyOSTOXQO5QOfHSCP++NvjnrXWdhOU6NAoGBALZIrLSffiteRUpWZcf6\nLYEveBA1IWr3Vtwv3l8pJ+TuWTIcuo8+aM4Nr84qielYvZMyXNojTfvjo9csvHLR\nwLmiDxZbqMGwxu5a5xTkRkJCGLytKZaOHW9cTmGFfjKdaOH9Yx+OXyu88LBcBVgT\nXJLKONRQufu8592AGzWrwE/U\n-----END PRIVATE KEY-----\n",
      "client_email": "gwele-33e7f@appspot.gserviceaccount.com",
      "client_id": "109317109560126231068",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gwele-33e7f%40appspot.gserviceaccount.com"
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email'
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close(); // Fermer le client

    return credentials.accessToken.data;
  }

  // Fonction pour envoyer la notification
  static Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
    required String contextType,
    required String contextData,
  }) async {
    final String serverKey = await getAccessToken();
    final String firebaseMessagingEndpoint = 'https://fcm.googleapis.com/v1/projects/gwele-33e7f/messages:send';

    final Map<String, dynamic> notificationMessage = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'type': contextType,
          'id': contextData,
        },
      }
    };

    // Convertir en chaîne JSON
    final String bodyJson = jsonEncode(notificationMessage);

    // Envoyer la requête POST avec la chaîne JSON dans le corps
    final response = await http.post(
      Uri.parse(firebaseMessagingEndpoint),
      headers: {
        'Authorization': 'Bearer $serverKey',
        'Content-Type': 'application/json',
      },
      body: bodyJson, // Le corps est maintenant au format JSON
    );

    if (response.statusCode == 200) {
      print('Notification envoyée avec succès.');
    } else {
      print('Erreur lors de l\'envoi de la notification : ${response.body}');
    }
  }
}
