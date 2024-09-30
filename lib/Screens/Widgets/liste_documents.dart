import 'package:flutter/material.dart';

class ListeDocuments extends StatefulWidget {
  final List<String> documents;

  const ListeDocuments({Key? key, required this.documents}) : super(key: key);

  @override
  _ListeDocumentsState createState() => _ListeDocumentsState();
}

class _ListeDocumentsState extends State<ListeDocuments> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.documents.map((docName) {
        // Découper le nom du fichier à partir du tiret
        String shortenedName = docName.split(':').last;

        return ListTile(
          leading: const Icon(Icons.insert_drive_file),
          title: Text(
            shortenedName, // Afficher la partie après le tiret
          ),
        );
      }).toList(),
    );
  }
}
