import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomNavBar extends StatefulWidget {
  final Function(int) onTap;
  const CustomBottomNavBar({Key? key, required this.onTap}) : super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: _selectedIndex,
      //height: 60,
      items: const <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.person, size: 30, color: Colors.white),
        Icon(Icons.payment, size: 30, color: Colors.white),
      ],
      color: Colors.blue,
      buttonBackgroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      //animationCurve: Curves.ease,
      animationDuration: const Duration(milliseconds: 600),
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTap(index);
      },
    );
  }
}
