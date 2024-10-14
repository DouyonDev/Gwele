import 'package:flutter/material.dart';
import 'package:gwele/Colors.dart';
import 'package:gwele/Models/Client.dart';
import 'package:gwele/Services/UtilsService.dart';

import '../../Models/Offre.dart';
import '../details_offres.dart';

class AffichageClient extends StatelessWidget {
  final Client clientData;

  AffichageClient({required this.clientData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailOffre( : clientData,),
          ),
        );*/
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  radius: 40.0,
                  backgroundImage: AssetImage('assets/images/boy.png') as ImageProvider,
                ),
                subtitle: Text('${clientData.email}'),
                title: Text(
                  '${clientData?.prenom} ${clientData?.nom}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
                ],
              ),
          ),
        ),
      );
  }
}
