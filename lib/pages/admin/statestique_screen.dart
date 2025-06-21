import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StatestiquePage extends StatefulWidget {
  const StatestiquePage({super.key});

  @override
  State<StatestiquePage> createState() => _StatestiquePageState();
}

class _StatestiquePageState extends State<StatestiquePage> {
  final Color primaryColor = const Color.fromARGB(255, 26, 142, 234);
  final supabase = Supabase.instance.client;

  int totalVoyages = 0;
  int acceptedVoyages = 0;
  int rejectedVoyages = 0;
  int pendingVoyages = 0;
  int totalUsers = 0;
  int totalStag = 0;
  int totalOrg = 0;

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
        totalUsers = users.length - 1;
        acceptedVoyages = voyages.where((v) => v['status'] == 'accepted').length;
        rejectedVoyages = voyages.where((v) => v['status'] == 'rejected').length;
        pendingVoyages = voyages.where((v) => v['status'] == 'en_cours').length;
        totalStag = users.where((u) => u['role'] == "stagiaire").length;
        totalOrg = users.where((u) => u['role'] == 'organisateur').length;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur de chargement des stats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color color = Colors.blue}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [color.withOpacity(0.05), Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  int _selectedIndex = 2;
  void _navigate(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FadeIn(
          duration: const Duration(milliseconds: 800),
          child: const Text(
            'Statestique',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
        // actions: [
        //   BounceInRight(
        //     duration: const Duration(milliseconds: 1000),
        //     child: IconButton(
        //       icon: const Icon(Icons.notifications, size: 26),
        //       onPressed: () {},
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStatCard("Total Voyages", totalVoyages.toString(), Icons.flight_takeoff, color: primaryColor),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildCircularStat(label: 'Acceptés', value: acceptedVoyages, total: totalVoyages, color: Colors.green),
                        buildCircularStat(label: 'Rejetés', value: rejectedVoyages, total: totalVoyages, color: Colors.red),
                        buildCircularStat(label: 'En Attente', value: pendingVoyages, total: totalVoyages, color: Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: _buildStatCard("Utilisateurs", totalUsers.toString(), Icons.people, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildCircularStat(label: 'Stagiaire', value: totalStag, total: totalUsers, color: Colors.blueGrey),
                        buildCircularStat(label: 'Oraganisateur', value: totalOrg, total: totalUsers, color: Color(0xFFFF8A65)),
                      
                      ],
                    ),
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
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                icon: Icon(Icons.bar_chart_outlined, color: Colors.grey[600]),
                selectedIcon: Icon(Icons.bar_chart, color: primaryColor),
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

  Widget buildVoyageBarChart({required int accepted, required int rejected, required int pending}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques des voyages',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: ([accepted.toDouble(), rejected.toDouble(), pending.toDouble()].reduce((a, b) => a > b ? a : b)) + 5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Acceptés');
                          case 1:
                            return const Text('Rejetés');
                          case 2:
                            return const Text('En Attente');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: accepted.toDouble(), color: Colors.green, borderRadius: BorderRadius.circular(4)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: rejected.toDouble(), color: Colors.redAccent, borderRadius: BorderRadius.circular(4)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: pending.toDouble(), color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCircularStat({required String label, required int value, required int total, Color color = Colors.blue}) {
    final double percent = total == 0 ? 0 : value / total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 10.0,
          animation: true,
          percent: percent.clamp(0.0, 1.0),
          center: Text(
            "$value",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor: color.withOpacity(0.1),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
