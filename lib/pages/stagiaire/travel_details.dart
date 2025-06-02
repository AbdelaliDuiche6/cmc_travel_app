import 'package:flutter/material.dart';

class TravelDetails extends StatelessWidget {
  const TravelDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Travel Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
