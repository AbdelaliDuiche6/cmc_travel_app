import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Main Page')), // or a landing widget
      bottomNavigationBar: NavigationBar(
        height: 50,
        elevation: 0,
        
        selectedIndex: 0, // can ignore selection state if you push pages
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_2), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Notification'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
