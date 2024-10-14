import 'package:flutter/material.dart';

import '../../../Colors.dart';

class SideMenuComptableWidget extends StatefulWidget {
  final Function(int) onItemSelected; // Callback pour notifier le changement de page

  const SideMenuComptableWidget({super.key, required this.onItemSelected});

  @override
  _SideMenuComptableWidgetState createState() => _SideMenuComptableWidgetState();
}

class _SideMenuComptableWidgetState extends State<SideMenuComptableWidget> {
  int _selectedIndex = 0; // Index pour suivre l'élément sélectionné

  // Méthode pour gérer la sélection d'un élément
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor, // Appliquer la couleur de fond du drawer
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor, // Appliquer la couleur primaire au header
            ),
            child: Text(
              'GWELE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Options du drawer avec gestion de la couleur de sélection
          optionDrawer(
            'Reunions',
            Icon(Icons.home),
                () => _onItemTapped(0),
            isSelected: _selectedIndex == 0, // Vérifie si l'option est sélectionnée
          ),
          optionDrawer(
            'Tâches',
            Icon(Icons.task),
                () => _onItemTapped(1),
            isSelected: _selectedIndex == 1,
          ),
          optionDrawer(
            'Clients',
            Icon(Icons.group),
                () => _onItemTapped(2),
            isSelected: _selectedIndex == 2,
          ),
          optionDrawer(
            'Offres',
            Icon(Icons.local_offer),
                () => _onItemTapped(3),
            isSelected: _selectedIndex == 3,
          ),
          optionDrawer(
            'Profil',
            Icon(Icons.account_balance),
                () => _onItemTapped(4),
            isSelected: _selectedIndex == 4,
          ),
          optionDrawer(
            '',
            Icon(Icons.exit_to_app),
                () {
              // Logique de déconnexion
            },
            isSelected: false, // Déconnexion n'est jamais sélectionnée
          ),
        ],
      ),
    );
  }

  // Méthode pour générer un ListTile avec gestion de la sélection
  Widget optionDrawer(String label, Icon icon, VoidCallback action, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        color: isSelected ? backgroundColor : Colors.transparent, // Couleur de l'option sélectionnée
      ),
      child: ListTile(
        leading: icon,
        title: Text(label, style: TextStyle(color: isSelected ? primaryColor : secondaryColor)),
        onTap: action, // Action lors du clic
      ),
    );
  }
}
