import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gwele/Screens/Admin/ajout_Manager.dart';
import 'package:gwele/Screens/Lead/ajout_reunion.dart';
import 'package:gwele/Screens/Manager/ajout_Membre.dart';
import 'package:gwele/Screens/dashbord/const/constant.dart';

import '../profil.dart';
import '../Manager/ajout_equipe.dart';

class Manager extends StatefulWidget {
  @override
  ManagerState createState() => ManagerState();
}

class ManagerState extends State<Manager> {
  int _selectedIndex = 0; // Index pour suivre l'élément sélectionné

  // Liste des widgets pour chaque page
  static final List<Widget> _pages = <Widget>[
    AjoutReunion(),
    AjoutEquipe(),
    AjoutMembre(),
    Profil(),
  ];

  // Méthode pour changer de page à partir de la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      if (index >= 0 && index < _pages.length) {
        _selectedIndex = index; // Met à jour l'index lorsqu'une icône est cliquée
      } else {
        print('Index hors limite : $index');
      }
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
          Icon(Icons.task_alt_outlined, size: 30, color: Colors.white),
          Icon(Icons.school, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: primaryColor,
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
