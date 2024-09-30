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
  final PageController _pageController = PageController(); // Controller pour PageView

  // Liste des widgets pour chaque page
  static final List<Widget> _pages = <Widget>[
    AjoutReunion(),
    AjoutManager(),
    MesReunions(),
    AjoutEquipe(),
    Profil(),
  ];

  // Méthode pour changer de page à partir de la barre de navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ); // Anime le changement de page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // Met à jour l'index lors du glissement
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: <Widget>[
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

  @override
  void dispose() {
    _pageController.dispose(); // Libérer les ressources du contrôleur
    super.dispose();
  }
}
