import 'package:flutter/material.dart';

///  Created by abdoulaye.douyon on 05/09/2024.

class MessageModale extends StatelessWidget {
  final String title;
  final String content;

  const MessageModale({required this.title, required this.content, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Icon(Icons.check, color: Colors.green),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}
