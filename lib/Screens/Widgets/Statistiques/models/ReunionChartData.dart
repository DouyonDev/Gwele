import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';


class ChartData {
  List<PieChartSectionData> generateChartData(int programme, int enCours, int termine) {
    final total = programme + enCours + termine;

    return [
      PieChartSectionData(
        color: primaryColor,
        value: total > 0 ? (programme / total) * 100 : 0,
        showTitle: false,
        radius: 25,
      ),
      PieChartSectionData(
        color: const Color(0xFF26E5FF),
        value: total > 0 ? (enCours / total) * 100 : 0,
        showTitle: false,
        radius: 22,
      ),
      PieChartSectionData(
        color: const Color(0xFFFFCF26),
        value: total > 0 ? (termine / total) * 100 : 0,
        showTitle: false,
        radius: 19,
      ),
    ];
  }
}
