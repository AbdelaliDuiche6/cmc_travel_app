import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:cmc_travel_app/pages/admin/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final supabase = Supabase.instance.client;
  final Color primaryColor = const Color(0xFF3AB796);
  final Color secondaryColor = const Color(0xFF3AABB7);

  List<dynamic> voyages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVoyages();
  }

  Future<void> fetchVoyages() async {
    try {
      final response = await supabase
          .from('Voyage')
          .select('*, profiles(name)')
          .eq('status', 'en_cours')
          .order('date', ascending: true);

      setState(() {
        voyages = response;
        isLoading = false;
      });
    } catch (error) {
      print("Erreur de chargement: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _selectedIndex = 0;
  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });

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

  void _previewVoyage(dynamic voyage) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      voyage['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Ajout de l'image en haut du dialogue
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: voyage['image_url'] != null && voyage['image_url'].isNotEmpty
                      ? Image.network(
                          voyage['image_url'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      "Organisateur: ${voyage['profiles']['name']}",
                      iconColor: primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.category,
                      "Type: ${voyage['type']}",
                      iconColor: primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.description,
                      "Description: ${voyage['description']}",
                      iconColor: primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      "Date: ${voyage['date']}",
                      iconColor: primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.attach_money,
                      "Prix: ${voyage['price_per_person']} DH",
                      iconColor: primaryColor,
                    ),
                    _buildInfoRow(
                      Icons.people,
                      "Places disponibles: ${voyage['nbr_places']}",
                      iconColor: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildVoyageCard(dynamic voyage, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _previewVoyage(voyage),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                      voyage['image_url'] ,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voyage['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Organisé par ${voyage['profiles']['name']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    voyage['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "${voyage['nbr_places']} places",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                      label: const Text("Détails"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _previewVoyage(voyage),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text("Accepter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final response = await supabase
                              .from('Voyage')
                              .update({'status': 'accepted'})
                              .eq('id', voyage['id'])
                              .select();

                          if (response != null && response.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voyage accepté'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            setState(() {
                              voyages.removeAt(index);
                            });
                          } else {
                            throw Exception("Update failed or returned no result.");
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text("Rejeter"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final response = await supabase
                              .from('Voyage')
                              .update({'status': 'rejected'})
                              .eq('id', voyage['id'])
                              .select();

                          if (response != null && response.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voyage rejeté'),
                                backgroundColor: Colors.red,
                              ),
                            );

                            setState(() {
                              voyages.removeAt(index);
                            });
                          } else {
                            throw Exception("Update failed or returned no result.");
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $error'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Commandes Trips',
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
            icon: const Icon(Icons.notifications, size: 26),
            onPressed: () {},
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3AB796)),
              ),
            )
          : voyages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.airplanemode_active,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun voyage en cours',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: fetchVoyages,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: voyages.length,
                    itemBuilder: (context, index) =>
                        _buildVoyageCard(voyages[index], index),
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