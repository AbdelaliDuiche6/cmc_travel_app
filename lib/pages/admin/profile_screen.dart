import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/notification_screen.dart';
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
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
        title: Text("profile page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Center(
        child: Text("Profile Screen"),
      ),
      bottomNavigationBar: Theme(
  data: Theme.of(context).copyWith(
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Colors.blue.withOpacity(0.1),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: Colors.blue);
        }
        return const IconThemeData(color: Colors.grey);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
  if (states.contains(MaterialState.selected)) {
    return const TextStyle(color: Colors.blue);
  }
  return const TextStyle(color: Colors.grey);
}),
    ),
  ),
  child: NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: _navigate,
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.person_2), label: 'Users'),
      NavigationDestination(icon: Icon(Icons.notifications), label: 'Notification'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ],
  ),
),

    );
  }
}