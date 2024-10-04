import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gwele/Models/Utilisateur.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Vérifier si la collection 'users' est vide
  Future<void> checkAndCreateAdmin() async {
    try {
      // Vérifier si la collection 'users' contient des documents
      final QuerySnapshot userCollection = await _firestore.collection('utilisateurs').limit(1).get();

      if (userCollection.docs.isEmpty) {
        // Si la collection est vide, on crée un admin par défaut
        await _createAdmin();
      } else {
        print("La collection 'utilisateurs' existe déjà.");
      }
    } catch (e) {
      print("Erreur lors de la vérification de la collection 'users': $e");
    }
  }

  // Fonction pour créer un admin par défaut
  Future<void> _createAdmin() async {
    try {
      Utilisateur admin = Utilisateur(
        id: '',
        email: "admin@gwele.com",
        role: "ADMIN",
        nom: "Administrateur",
        prenom: "Gwele",
        imageUrl: 'assets/images/logoGwele.png',
        userMere: '',
        notificationToken: '',
        tachesAssignees: [],
        reunions: [],
      );
      // Création de l'utilisateur Firebase pour l'admin
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: admin.email,
        password: "12345678", // Remplacer par un mot de passe sécurisé
      );

      // Enregistrement des informations de l'admin dans Firestore
      await _firestore.collection('utilisateurs').doc(userCredential.user!.uid).set(admin.toMap());

      print("Admin créé avec succès.");
    } catch (e) {
      print("Erreur lors de la création de l'admin: $e");
    }
  }
}
