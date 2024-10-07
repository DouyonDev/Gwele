import 'package:flutter/material.dart';

///  Created by abdoulaye.douyon on 05/09/2024.

class MessageModaleErreur extends StatelessWidget {
  final String title;
  final String content;

  const MessageModaleErreur({required this.title, required this.content, Key? key}) : super(key: key);

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
          child: const Icon(Icons.error, color: Colors.red),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}
