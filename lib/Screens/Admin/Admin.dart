import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../Participant/mes_reunions.dart';
import '../profil.dart';
import '../Admin/ajout_Manager.dart';
import '../Lead/ajout_reunion.dart';
import '../Manager/ajout_equipe.dart';

class Admin extends StatefulWidget {
  @override
  AdminState createState() => AdminState();
}

class AdminState extends State<Admin> {
  int _selectedIndex = 0; // Index pour suivre l'élément sélectionné

  // Liste des widgets pour chaque page
  static final List<Widget> _pages = <Widget>[
    AjoutReunion(),
    AjoutEquipe(),
    MesReunions(),
    Profil(),
  ];

  // Méthode pour changer de page à partir de la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'index lorsqu'une icône est cliquée
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex], // Affiche la page correspondant à l'index sélectionné
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.business, size: 30, color: Colors.white),
          Icon(Icons.school, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: Colors.blue[800]!,
        buttonBackgroundColor: Colors.amber[800]!,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          _onItemTapped(index); // Appelle la méthode pour changer de page
        },
      ),
    );
  }
}
