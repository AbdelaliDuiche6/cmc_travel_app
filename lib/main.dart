import 'package:cmc_travel_app/pages/organizer/org_home_page.dart';
import 'package:cmc_travel_app/pages/organizer/org_profile_page.dart';
import 'package:cmc_travel_app/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  OrgHomePage(),
    );
  }
}


