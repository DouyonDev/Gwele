
import 'package:flutter/material.dart';
import '../Colors.dart';
import '../Services/BoutonService.dart';

class PasswordChange extends StatefulWidget {
  @override
  _PasswordChangeState createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {

  final BoutonService boutonService = BoutonService();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('assets/images/reset-password.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                      "Changer de mot de passe",
                      style: TextStyle(
                        color: secondaryColor,
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Ancien mot de passe',
                      labelStyle: TextStyle(color: secondaryColor),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 5,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: thirdColor,
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () {boutonService.changePassword(
                        context,
                        _oldPasswordController.text,
                        _newPasswordController.text,
                        _confirmPasswordController.text
                      );
                        },
                      child: const Text('Modifier'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
