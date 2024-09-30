import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FichiersService {
  // Uploader le fichier dans Firebase Storage
  Future<String> uploaderFichier(File file, String fileName) async {
    String fullFileName = '${DateTime.now().millisecondsSinceEpoch}:$fileName';

    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child("reunions/$fullFileName");

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload du fichier: $e');
      throw e;
    }
  }

  // Sélectionner le fichier et retourner l'URL et le nom du fichier
  Future<String> selectionnerFichier() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name; // Extraire le nom du fichier
      try {
        String downloadUrl =
            await uploaderFichier(file, fileName); // Uploader le fichier
        return fileName;
      } catch (e) {
        return 'Erreur lors de la sélection ou de l\'upload du fichier: $e';
      }
    } else {
      // Aucun fichier sélectionné
      return 'Aucun fichier selectionné';
    }
  }
}
