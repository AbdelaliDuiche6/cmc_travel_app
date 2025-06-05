import 'package:flutter/material.dart';

class ProfileStagiaire extends StatefulWidget {
  const ProfileStagiaire({super.key});

  @override
  State<ProfileStagiaire> createState() => _ProfileStagiaireState();
}

class _ProfileStagiaireState extends State<ProfileStagiaire> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 26, 142, 234),
        ),
      ),
    );
  }
}
