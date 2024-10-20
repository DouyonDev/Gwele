import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Screens/Widgets/Statistiques/screens/Chart.dart';

class ReunionCharts extends StatelessWidget {
  const ReunionCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
              children: [
                const Text(
                  'Aujourd\'hui',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Chart(),
                //Scheduled(),
              ],
            ),
        ),
      ),
    );
  }
}
