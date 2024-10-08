import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UtilsService {
  String formatDate(DateTime date) {
    // Formater la date au format 'YYYY-MM-DD'
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  // Sélection de l'heure avec setState passé en paramètre
  Future<void> selectTime(
      BuildContext context, bool isStart, Function(TimeOfDay) updateState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      updateState(picked); // Appelle la fonction de mise à jour de l'état
    }
  }

  // Sélection de la date
  // Fonction de sélection de date
  Future<void> selectDate(
      BuildContext context, DateTime initialDate, Function(DateTime) updateDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      updateDate(picked);  // Appelle la fonction de mise à jour de la date
    }
  }

}