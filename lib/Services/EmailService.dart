import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  final String _sendGridApiKey = 'YOUR_SENDGRID_API_KEY';

  Future<void> sendEmail(String toEmail, String subject, String body) async {
    final Uri url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final Map<String, dynamic> emailData = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail}
          ],
          'subject': subject,
        },
      ],
      'from': {'email': 'your-email@example.com'},
      'content': [
        {
          'type': 'text/plain',
          'value': body,
        },
      ],
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_sendGridApiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(emailData),
    );

    if (response.statusCode != 202) {
      throw Exception('Echec de l\'envoi de votre email: ${response.body}');
    }
  }
}
