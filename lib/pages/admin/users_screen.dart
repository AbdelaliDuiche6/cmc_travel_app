import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/notification_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  int _selectedIndex = 1;
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
        title: Text("users screen"),
      ),
      body: Center(
        child: Text("users Screen"),
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