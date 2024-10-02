import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FichiersService {
  // Uploader le fichier dans Firebase Storage
  Future<String> uploaderFichierReunion(File file, String fileName) async {
    String fullFileName = '${DateTime.now().millisecondsSinceEpoch}:$fileName';

    try {
      Reference storageRef = FirebaseStorage.instance.ref().child("reunions/$fullFileName");
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload du fichier: $e');
      throw e;
    }
  }

  // Sélectionner le fichier et l'ajouter à la liste
  Future<File?> selectionnerFichier() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }

  // Uploader le fichier dans Firebase Storage
  Future<String> uploaderFichierOffre(File file, String fileName) async {
    String fullFileName = '${DateTime.now().millisecondsSinceEpoch}:$fileName';

    try {
      Reference storageRef = FirebaseStorage.instance.ref().child("offres/$fullFileName");
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload du fichier: $e');
      throw e;
    }
  }
}
