import 'package:flutter/material.dart';
import 'package:gwele/Screens/Lead/Les_offres.dart';
import 'package:gwele/Screens/Lead/Les_taches.dart';
import 'package:gwele/Screens/Manager/les_reunions_manager.dart';
import 'package:gwele/Screens/Manager/mes_comptables.dart';
import 'package:gwele/Screens/Manager/mes_equipes.dart';
import 'package:gwele/Screens/Manager/side_menu_manager_widget.dart';
import 'package:gwele/Screens/Widgets/Statistiques/screens/ReunionCharts.dart';
import 'package:gwele/Screens/dashbord/util/responsive.dart';
import 'package:gwele/Screens/profil.dart';

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
      endDrawer: Responsive.isMobile(context)
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

/*Widget build(BuildContext context) {
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
      ),
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
      ),
    );
  }*/

  /*Widget optionDrawer(String label, Icon icon, VoidCallback action) {
    return ListTile(
      leading: icon,
      title: Text(label),
      onTap: action, // Ici, on passe l'action (un callback) au onTap
    );
  }*/

