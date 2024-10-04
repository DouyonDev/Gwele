class UtilsService {
  String formatDate(DateTime date) {
    // Formater la date au format 'YYYY-MM-DD'
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}