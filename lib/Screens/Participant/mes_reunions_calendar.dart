import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Reunion.dart';
import 'package:gwele/Screens/Widgets/affichage_reunion.dart';
import 'package:gwele/Services/UtilsService.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReunionCalendarPage extends StatefulWidget {
  @override
  _ReunionCalendarPageState createState() => _ReunionCalendarPageState();
}

class _ReunionCalendarPageState extends State<ReunionCalendarPage> {
  DateTime _selectedDate = DateTime.now(); // Date sélectionnée
  CalendarFormat _calendarFormat = CalendarFormat.month; // Format du calendrier

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
        title: const Text("Liste de vos réunions"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor), // Icône retour
          onPressed: () {
            Navigator.pop(context); // Retourner à l'écran précédent
          },
        ),
      ),
      body: Column(
        children: [
          // Calendrier en haut
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                print(UtilsService().formatDate(_selectedDate));
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          // Liste des réunions en fonction de la date sélectionnée
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reunions')
                  .where('dateReunion', isEqualTo: UtilsService().formatDate(_selectedDate))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucune réunion pour cette date.'));
                }


                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Créez un objet Reunion à partir des données
                    final reunion = Reunion.fromDocument(data, doc.id);
                    return AffichageReunion(reunionData: reunion); // Passez l'objet Reunion ici
                  }).toList(),
                );
              },

            ),
          ),
        ],
      ),
    );
  }
}
