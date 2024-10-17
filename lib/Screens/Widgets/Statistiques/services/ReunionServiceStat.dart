import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Services/ReunionService.dart';

class ReunionServiceStat {
  // Méthode pour compter les réunions par statut
  Future<int> compterReunionsParStatut(String statut) async {
    try {
      // Récupérer la liste des réunions
      List<Reunion> reunions = await ReunionService().obtenirLesReunions();

      // Assurez-vous que les données sont correctes
      DateTime toDay = DateTime.now();
      List<Reunion> reunionsDuJour = reunions.where((r) {
        return r.dateReunion.year == toDay.year &&
            r.dateReunion.month == toDay.month &&
            r.dateReunion.day == toDay.day;
      }).toList();

      // Compteur selon le statut
      int compteur = reunionsDuJour.where((reunion) => reunion.statut == statut).length;

      return compteur;
    } catch (e) {
      print("Erreur lors du comptage des réunions: $e");
      return 0;
    }
  }

  Future<int> compterReunionsProgrammer() => compterReunionsParStatut("En attente");

  Future<int> compterReunionsEnCours() => compterReunionsParStatut("En cours");

  Future<int> compterReunionsTerminer() => compterReunionsParStatut("Terminer");
}
