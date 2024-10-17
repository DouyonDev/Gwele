import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Screens/Widgets/Statistiques/models/ReunionChartData.dart';
import 'package:gwele/Screens/Widgets/Statistiques/services/ReunionServiceStat.dart';
import 'package:gwele/Services/ReunionService.dart';

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Reunion>? reunions;
  int programme = 0;
  int enCours = 0;
  int termine = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReunionData();
  }

  Future<void> _fetchReunionData() async {
    try {
      // Récupérer la liste des réunions
      reunions = await ReunionService().obtenirLesReunions();
      programme = await ReunionServiceStat().compterReunionsProgrammer();
      enCours = await ReunionServiceStat().compterReunionsEnCours();
      termine = await ReunionServiceStat().compterReunionsTerminer();
      print("programmer ${programme}");
      print("en cours ${enCours}");
      print("terminer ${termine}");
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
    } finally {
      setState(() {
        isLoading = false; // Mettre à jour l'état de chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final chartData = ChartData();
    final sections = chartData.generateChartData(programme, enCours, termine);
    final total = programme + enCours + termine;
    final percentage = total > 0 ? ((programme / total) * 100).toStringAsFixed(1) : '0';

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: sections,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  "$percentage%",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("of 100%"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
