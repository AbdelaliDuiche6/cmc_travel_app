import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatestiquePage extends StatefulWidget {
  const StatestiquePage({super.key});

  @override
  State<StatestiquePage> createState() => _StatestiquePageState();
}

class _StatestiquePageState extends State<StatestiquePage> {
  final Color primaryColor = const Color(0xFF3AB796);
  final Color secondaryColor = const Color(0xFF3AABB7);
  final supabase = Supabase.instance.client;

  int totalVoyages = 0;
  int acceptedVoyages = 0;
  int rejectedVoyages = 0;
  int pendingVoyages = 0;
  int totalUsers = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      final voyages = await supabase.from('Voyage').select();
      final users = await supabase.from('profiles').select();

      setState(() {
        totalVoyages = voyages.length;
        totalUsers = users.length;
        acceptedVoyages =
            voyages.where((v) => v['status'] == 'accepted').length;
        rejectedVoyages =
            voyages.where((v) => v['status'] == 'rejected').length;
        pendingVoyages = voyages.where((v) => v['status'] == 'en_cours').length;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur de chargement des stats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, {
    Color color = Colors.blue,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  int _selectedIndex = 2;
  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home (can be AdminScreen itself or another screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsersScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StatestiquePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statestique',
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 26),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatCard(
                      "Total Voyages",
                      totalVoyages.toString(),
                      Icons.flight_takeoff,
                    ),
                    _buildStatCard(
                      "Acceptés",
                      acceptedVoyages.toString(),
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      "Rejetés",
                      rejectedVoyages.toString(),
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    _buildStatCard(
                      "En Attente",
                      pendingVoyages.toString(),
                      Icons.hourglass_top,
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      "Utilisateurs",
                      totalUsers.toString(),
                      Icons.people,
                    ),
                  ],
                ),
              ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),)
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: NavigationBar(
            height: 70,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _navigate,
            backgroundColor: Colors.white,
            indicatorColor: primaryColor.withOpacity(0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 300),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.grey[600]),
                selectedIcon: Icon(Icons.home, color: primaryColor),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline, color: Colors.grey[600]),
                selectedIcon: Icon(Icons.people, color: primaryColor),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined,
                    color: Colors.grey[600]),
                selectedIcon:
                    Icon(Icons.bar_chart, color: primaryColor),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.grey[600]),
                selectedIcon: Icon(Icons.person, color: primaryColor),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
