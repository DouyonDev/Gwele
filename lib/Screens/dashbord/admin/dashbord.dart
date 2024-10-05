import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/message_page.dart';
import '../screens/profile_page.dart';
import '../screens/publication_page.dart';
import '../screens/signale_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/utilisateur_page.dart';


class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Liste des pages du Dashboard
  final List<Widget> _pages = [
    DashboardPage(),
    UtilisateurPage(),
    PublicationPage(),
    SignalePage(),
    ProfilePage(),
    MessagePage(),
  ];

  // Titre de chaque page correspondante
  final List<String> _pageTitles = [
    'Dashboard',
    'Utilisateurs',
    'Publications',
    'Signales',
    'Profil',
    'Messages'
  ];

  int _selectedIndex = 0; // Index de la page actuellement affichée

  // Méthode pour changer de page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Méthode pour se déconnecter
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout selon la taille de l'écran
    bool isMobile = MediaQuery.of(context).size.width < 600; // Détection d'un écran mobile

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex], style: const TextStyle(fontSize: 24, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: isMobile ? // Afficher le menu pour les mobiles
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ) : null, // Retire le bouton menu si non mobile
      ),
      drawer: isMobile ? _buildDrawer() : null, // Affiche le menu latéral si mobile
      body: Row(
        children: [
          if (!isMobile) _buildDrawer(), // Affiche le menu latéral si écran large
          Expanded(
            child: _pages[_selectedIndex], // Affiche la page correspondante
          ),
        ],
      ),
    );
  }

  // Menu latéral (Drawer)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF914B14)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', index: 0),
          _buildDrawerItem(icon: Icons.people, text: 'Utilisateurs', index: 1),
          _buildDrawerItem(icon: Icons.article, text: 'Publications', index: 2),
          _buildDrawerItem(icon: Icons.warning, text: 'Signales', index: 3),
          _buildDrawerItem(icon: Icons.person, text: 'Profil', index: 4),
          _buildDrawerItem(icon: Icons.message, text: 'Messages', index: 5),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se Déconnecter'),
            onTap: () {
              _signOut();
            },
          ),
        ],
      ),
    );
  }

  // Construction d'un item du menu latéral
  Widget _buildDrawerItem({required IconData icon, required String text, required int index}) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Color(0xFF914B14) : Colors.black),
      title: Text(text),
      selected: _selectedIndex == index,
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context); // Ferme le menu après sélection (sur mobile)
      },
    );
  }
}
