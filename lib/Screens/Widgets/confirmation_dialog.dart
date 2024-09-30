import 'package:flutter/material.dart';

///  Created by abdoulaye.douyon on 05/09/2024.

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: onCancel,
          child: const Icon(Icons.cancel, color: Colors.red),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Icon(Icons.check, color: Colors.green),
        ),
      ],
    );
  }
}

