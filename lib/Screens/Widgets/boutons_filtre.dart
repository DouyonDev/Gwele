import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final String status;
  final String selectedStatus;
  final void Function(String) onStatusSelected;

  FilterButton({
    required this.label,
    required this.status,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onStatusSelected(status);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedStatus == status ? primaryColor : Colors.white,
        minimumSize: const Size(10, 20), // Ajustez ici la longueur et la largeur du bouton
        textStyle: const TextStyle(
          fontSize: 10, // Ajustez ici la taille de la police
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Pour arrondir les coins si nécessaire
          side: BorderSide(color: selectedStatus == status ? Colors.transparent : Colors.black), // Ajoutez une bordure si nécessaire
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selectedStatus == status ? Colors.white : Colors.black, // Changement de couleur du texte
        ),
      ),
    );
  }
}
