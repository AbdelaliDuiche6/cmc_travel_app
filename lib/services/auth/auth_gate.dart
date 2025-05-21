import 'package:cmc_travel_app/pages/admin_screen.dart';
import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/pages/organizateur_screen.dart';
import 'package:cmc_travel_app/pages/stagiaire_screen.dart';
import 'package:cmc_travel_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // ✅ Updated to query the 'profiles' table, not 'User'
  Future<String?> fetchUserRole(String userId) async {
    final response = await Supabase.instance.client
        .from('profiles') // 👈 Correct table name
        .select('role')
        .eq('id', userId) // 👈 Must match auth.users.id
        .single();

    return response['role'];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          final userId = session.user.id;

          return FutureBuilder<String?>(
            future: fetchUserRole(userId),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data;

              if (role == 'admin') {
                return const AdminScreen(); // Replace with your Admin screen
              } else if (role == 'stagiaire') {
                return const StagiaireScreen();
              } else if (role == 'organisateur') {
                return const OrganizateurScreen(); // Replace with your Organisateur screen
              } else {
                return const LoginScreen(); // Fallback for unknown role
              }
            },
          );
        }

        return const LoginScreen(); // If not logged in
      },
    );
  }
}
