import 'package:flutter/material.dart';
import 'package:gwele/Screens/Lead/Les_offres.dart';
import 'package:gwele/Screens/Lead/Les_taches.dart';
import 'package:gwele/Screens/Manager/les_reunions_manager.dart';
import 'package:gwele/Screens/Manager/mes_comptables.dart';
import 'package:gwele/Screens/Manager/mes_equipes.dart';
import 'package:gwele/Screens/Manager/side_menu_manager_widget.dart';
import 'package:gwele/Screens/Widgets/Statistiques/screens/ReunionCharts.dart';
import 'package:gwele/Screens/profil.dart';
import 'package:gwele/Screens/utils.dart';

class Manager extends StatefulWidget {
  @override
  ManagerState createState() => ManagerState();
}

class ManagerState extends State<Manager> {
  int _selectedIndex = 0; // Index pour suivre l'élément sélectionné

  // Liste des widgets pour chaque page
  final List<Widget> _pages = <Widget>[
    LesReunionsManager(),
    LesTaches(),
    MesEquipes(),
    LesOffres(),
    MesComptables(),
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
    final isDesktop = Responsive.isDesktop(context);  // Vérifie si l'interface est sur un écran de bureau (desktop)

    return Scaffold(
      appBar: !isDesktop
          ? AppBar( // Ajouter une AppBar sur mobile avec un bouton pour ouvrir le drawer
        title: const Text('Manager'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Ouvre le drawer sur mobile
            },
          ),
        ),
      )
          : null, // Pas besoin de AppBar sur Desktop
      drawer: !isDesktop
          ? SizedBox(
        width: 250,
        child: SideMenuManagerWidget(onItemSelected: _onItemTapped),
      )
          : null,
      endDrawer: Responsive.isMobile(context) || Responsive.isTablet(context)
          ? SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: const ReunionCharts(),
      )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              Expanded(
                flex: 2,
                child: SizedBox(
                  child: SideMenuManagerWidget(onItemSelected: _onItemTapped),
                ),
              ),
            Expanded(
              flex: 7,
              child: _pages[_selectedIndex],  // Affiche la page correspondante à l'index
            ),
            if (isDesktop)
              const Expanded(
                flex: 3,
                child: ReunionCharts(),  // Panneau de résumé à droite sur Desktop
              ),
          ],
        ),
      ),
    );
  }
}