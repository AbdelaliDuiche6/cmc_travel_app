import 'package:cmc_travel_app/pages/stagiaire/screens/home_stagaire.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/notifications_stagiare.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/profile_stagiaire.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/trips_stagiaire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cmc_travel_app/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoZHR6eGRyYXV3YWltb25iamt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc3NTAzNzUsImV4cCI6MjA2MzMyNjM3NX0.ht0Yn2byTGRjyRVJa7kFBVCwT3hk-PCuKf_jcVnQEvw",
    url: "https://fhdtzxdrauwaimonbjkz.supabase.co",
  );

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TraineeScreen()));
}

class TraineeScreen extends StatefulWidget {
  const TraineeScreen({super.key});
  @override
  State<TraineeScreen> createState() => _TraineeScreenState();
}

class _TraineeScreenState extends State<TraineeScreen> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [
    HomeStagaire(),
    TripsStagiaire(),
    NotificationsStagiare(),
    ProfileStagiaire(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: screens.elementAt(_selectedIndex),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: _navigateBottomBar,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      selectedIconTheme: IconThemeData(color: kPrimaryColor),
      elevation: 0.0,
      currentIndex: _selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/home.svg'),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/trips.svg'),
          label: 'My Trips',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/notification.svg'),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/icons/profile.svg'),
          label: 'Profile',
        ),
      ],
    );
  }
}
