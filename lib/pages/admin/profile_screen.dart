import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
    final Color primaryColor = const Color(0xFF3AB796);
  final Color secondaryColor = const Color(0xFF3AABB7);
  int _selectedIndex = 3;
    void logout() async {
    final authService = AuthService();
    authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home (can be AdminScreen itself or another screen)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StatestiquePage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 26),
            onPressed: logout,
            color: Colors.red,
          ),
        ],
      ),
      body: Center(
        child: Text("Profile Screen"),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _navigate,
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.home, color: primaryColor),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.people, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.people, color: primaryColor),
              label: 'Utilisateurs',
            ),
            NavigationDestination(
              icon: Icon(Icons.stacked_bar_chart_rounded, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.stacked_bar_chart_rounded, color: primaryColor),
              label: 'Statestique',
            ),
            NavigationDestination(
              icon: Icon(Icons.person, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.person, color: primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),

    );
  }
}