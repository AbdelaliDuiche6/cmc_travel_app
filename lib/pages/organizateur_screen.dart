import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class OrganizateurScreen extends StatefulWidget {
  const OrganizateurScreen({super.key});

  @override
  State<OrganizateurScreen> createState() => _OrganizateurScreenState();
}

class _OrganizateurScreenState extends State<OrganizateurScreen> {
  void logout() async {
    // Implement your logout logic here
    // For example, you can call a method from your auth service to sign out
    // await AuthService().signOut();
    // After signing out, navigate to the login screen
    final authService = AuthService();
    authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organisateur Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Organizateur Screen!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: logout,
        
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}