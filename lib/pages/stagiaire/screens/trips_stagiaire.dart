import 'package:flutter/material.dart';

class TripsStagiaire extends StatefulWidget {

  const TripsStagiaire({super.key});

  @override
  State<TripsStagiaire> createState() => _TripsStagiaireState();
}

class _TripsStagiaireState extends State<TripsStagiaire> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Trips',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 26, 142, 234),
        ),
      ),
    );
  }
}
