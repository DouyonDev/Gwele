import 'package:gwele/Services/UtilsService.dart';

class Paiement {
  String id;
  double montant;
  DateTime datePaiement;
  String modePaiement; // Par exemple : "Carte", "Virement", "Espèces", etc.
  String idFacture; // ID de la facture à laquelle ce paiement est lié

  Paiement({
    required this.id,
    required this.montant,
    required this.datePaiement,
    required this.modePaiement,
    required this.idFacture,
  });

  // Convertir un objet Paiement en Map pour l'envoyer à Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'datePaiement': UtilsService().formatDate(datePaiement),
      'modePaiement': modePaiement,
      'idFacture': idFacture,
    };
  }

  // Créer un Paiement à partir d'une Map
  factory Paiement.fromMap(Map<String, dynamic> map, String id) {
    return Paiement(
      id: id,
      montant: map['montant']?.toDouble() ?? 0.0,
      datePaiement: DateTime.parse(map['datePaiement'] ?? DateTime.now().toIso8601String()),
      modePaiement: map['modePaiement'] ?? '',
      idFacture: map['idFacture'] ?? '',
    );
  }
}
