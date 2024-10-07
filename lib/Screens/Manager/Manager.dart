import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:gwele/Screens/Lead/Les_offres.dart';
import 'package:gwele/Screens/Lead/Les_taches.dart';
import 'package:gwele/Screens/Lead/les_reunions.dart';
import 'package:gwele/Screens/Manager/mes_comptables.dart';
import 'package:gwele/Screens/Manager/mes_equipes.dart';
import 'package:gwele/Screens/dashbord/const/constant.dart';
import '../profil.dart';

class Manager extends StatefulWidget {
  @override
  ManagerState createState() => ManagerState();
}

class ManagerState extends State<Manager> {
  int _selectedIndex = 0; // Index pour suivre l'élément sélectionné

  // Liste des widgets pour chaque page
  static final List<Widget> _pages = <Widget>[
    LesReunions(),
    LesTaches(),
    MesEquipes(),
    Profil(),
    LesOffres(),
    MesComptables(),
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
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: primaryColor,
      ),
      extendBody: true,
      body: _pages[_selectedIndex], // Affiche la page correspondant à l'index sélectionné
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            optionDrawer(
              'Accueil',
              Icon(Icons.home),
                  () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            optionDrawer(
              'Tâches',
              Icon(Icons.task),
                  () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            optionDrawer(
              'Équipes',
              Icon(Icons.group),
                  () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            optionDrawer(
              'Offres',
              Icon(Icons.group),
                  () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            optionDrawer(
              'Comptables',
              Icon(Icons.countertops),
                  () {
                _onItemTapped(5);
                Navigator.pop(context);
              },
            ),
            optionDrawer(
              'Profil',
              Icon(Icons.person),
                  () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            optionDrawer(
              'Déconnexion',
              Icon(Icons.exit_to_app),
                  () {
                // Ajoutez votre logique de déconnexion ici
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),/*
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.task_alt_outlined, size: 30, color: Colors.white),
          Icon(Icons.surround_sound, size: 30, color: Colors.white),
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
      ),*/
    );
  }

  Widget optionDrawer(String label, Icon icon, VoidCallback action) {
    return ListTile(
      leading: icon,
      title: Text(label),
      onTap: action, // Ici, on passe l'action (un callback) au onTap
    );
  }

}
