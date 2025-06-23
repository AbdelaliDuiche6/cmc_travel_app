import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
class StatestiquePage extends StatefulWidget {
  const StatestiquePage({super.key});

  @override
  State<StatestiquePage> createState() => _StatestiquePageState();
}

class _StatestiquePageState extends State<StatestiquePage> {
  final Color primaryColor = const Color.fromARGB(255, 26, 142, 234);
  final Color secondaryColor = Color.fromARGB(255, 0, 0, 0);
  final supabase = Supabase.instance.client;

  int totalVoyages = 0;
  int acceptedVoyages = 0;
  int rejectedVoyages = 0;
  int pendingVoyages = 0;
  int totalUsers = 0;
  int totalStag = 0;
  int totalOrg = 0;
  int totalRes = 0;
  int reservationEncour = 0;
  int reservationTerminee = 0;

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
      final reservations = await supabase.from('Reservation').select();

      setState(() {
        totalVoyages = voyages.length;
        totalUsers = users.length - 1;
        acceptedVoyages =
            voyages.where((v) => v['status'] == 'accepted').length;
        rejectedVoyages =
            voyages.where((v) => v['status'] == 'rejected').length;
        pendingVoyages = voyages.where((v) => v['status'] == 'en_cours').length;
        totalStag = users.where((u) => u['role'] == "stagiaire").length;
        totalOrg = users.where((u) => u['role'] == 'organisateur').length;
        totalRes = reservations.length;
        reservationEncour =
            reservations.where((r) => r['payment_state'] == false).length;
        reservationTerminee =
            reservations.where((r) => r['payment_state'] == true).length;

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
  String svgAssetPath, {
  Color color = Colors.blue,
}) {
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
            child: SvgPicture.asset(
              svgAssetPath,
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        toolbarHeight: 70,
        backgroundColor: primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: const Text(
          "Commands Trips",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStatCard(
                        "Total Voyages",
                        totalVoyages.toString(),
                        "assets/images/trip.svg",
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,  // Pour permettre le défilement horizontal
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildCircularStat(
                              label: 'Acceptés',
                              value: acceptedVoyages,
                              total: totalVoyages,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10,),
                            buildCircularStat(
                              label: 'Rejetés',
                              value: rejectedVoyages,
                              total: totalVoyages,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10,),
                            buildCircularStat(
                              label: 'En Attente',
                              value: pendingVoyages,
                              total: totalVoyages,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: _buildStatCard(
                        "Utilisateurs",
                        totalUsers.toString(),
                        "assets/images/users.svg",
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildCircularStat(
                            label: 'Stagiaire',
                            value: totalStag,
                            total: totalUsers,
                            color: Colors.blueGrey,
                          ),
                          buildCircularStat(
                            label: 'Oraganisateur',
                            value: totalOrg,
                            total: totalUsers,
                            color: Color(0xFFFF8A65),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: _buildStatCard(
                        "Reservations",
                        totalRes.toString(),
                        "assets/images/reservation.svg",
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildCircularStat(
                            label: 'En Cours',
                            value: reservationEncour,
                            total: totalRes,
                            color: Colors.red,
                          ),
                          buildCircularStat(
                            label: 'Payée',
                            value: reservationTerminee,
                            total: totalRes,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withOpacity(0.95), Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, -2),
              spreadRadius: -5,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: NavigationBar(
            height: 85,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              HapticFeedback.lightImpact(); // Add haptic feedback
              setState(() => _selectedIndex = index);
              _navigate(index);
            },
            backgroundColor: Colors.transparent,
            indicatorColor: primaryColor.withOpacity(0.15),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 400),
            destinations: [
              _buildAnimatedDestination(
                index: 0,
                selectedIcon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
                label: 'Home',
              ),
              _buildAnimatedDestination(
                index: 1,
                selectedIcon: Icons.people_rounded,
                unselectedIcon: Icons.people_outline_rounded,
                label: 'Users',
              ),
              _buildAnimatedDestination(
                index: 2,
                selectedIcon: Icons.bar_chart_rounded,
                unselectedIcon: Icons.bar_chart_outlined,
                label: 'Stats',
              ),
              _buildAnimatedDestination(
                index: 3,
                selectedIcon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildAnimatedDestination({
    required int index,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return NavigationDestination(
      icon: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 1.0 + (value * 0.15), // Scale animation
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 8.0 : 4.0),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  color:
                      isSelected
                          ? primaryColor
                          : secondaryColor.withOpacity(0.8),
                  size: isSelected ? 26 : 24,
                  key: ValueKey<bool>(isSelected),
                ),
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }

  Widget buildVoyageBarChart({
    required int accepted,
    required int rejected,
    required int pending,
  }) {
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
                maxY:
                    ([
                      accepted.toDouble(),
                      rejected.toDouble(),
                      pending.toDouble(),
                    ].reduce((a, b) => a > b ? a : b)) +
                    5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
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
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: accepted.toDouble(),
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: rejected.toDouble(),
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: pending.toDouble(),
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCircularStat({
    required String label,
    required int value,
    required int total,
    Color color = Colors.blue,
  }) {
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
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
