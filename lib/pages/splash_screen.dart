import 'package:cmc_travel_app/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 26, 142, 234),
        body: Center(
          child: 
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  AuthGate(),
                    ),
                  );
                },
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 500,
                  height: 500,
                  semanticsLabel: 'CMC TRAVEL',
                ),
              ), 
              // Image.asset('assets/images/logo-cmc-travel.png', width: 500,) 
          ),
        ),
      );
  }
}
