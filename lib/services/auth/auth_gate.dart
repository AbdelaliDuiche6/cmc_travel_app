import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/pages/organizer/org_home_page.dart';
import 'package:cmc_travel_app/pages/stagiaire_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> fetchUserRole(String userId) async {
    final response =
        await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', userId)
            .single();

    return response['role'];
  }

  Future<bool> getCurrentUserActive(String userId) async {
    final response =
        await Supabase.instance.client
            .from('profiles')
            .select('is_active')
            .eq('id', userId)
            .single();
    return response['is_active'];
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

          // On attend à la fois le rôle et l'état actif
          return FutureBuilder<Map<String, dynamic>>(
            future: _getRoleAndStatus(userId),
            builder: (context, resultSnapshot) {
              if (resultSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final data = resultSnapshot.data;
              if (data == null) {
                return const LoginScreen(); // fallback en cas d'erreur
              }

              final role = data['role'] as String?;
              final isActive = data['is_active'] as bool;
              if (!isActive) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Votre compte est désactivé. Veuillez contacter l'administrateur.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text("Se déconnecter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (role == 'admin') {
                return const AdminScreen();
              } else if (role == 'stagiaire') {
                return const StagiaireScreen();
              } else if (role == 'organisateur') {
                return const OrgHomePage(); // Replace with your Organisateur screen
              } else {
                return const LoginScreen(); // rôle inconnu
              }
            },
          );
        }

        return const LoginScreen(); // pas connecté
      },
    );
  }

  /// Combine le rôle + état actif
  Future<Map<String, dynamic>> _getRoleAndStatus(String userId) async {
    final response =
        await Supabase.instance.client
            .from('profiles')
            .select('role, is_active')
            .eq('id', userId)
            .single();

    return {'role': response['role'], 'is_active': response['is_active']};
  }
}
