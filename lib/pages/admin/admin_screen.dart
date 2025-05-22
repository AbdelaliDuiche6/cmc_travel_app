import 'package:cmc_travel_app/pages/admin/notification_screen.dart';
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
          .select()
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  int _selectedIndex = 0;
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
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
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
      appBar: AppBar(title: Center(child: const Text('Commends Trips'))),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : voyages.isEmpty
              ? const Center(child: Text('Aucun voyage en cours'))
              : ListView.builder(
                itemCount: voyages.length,
                itemBuilder: (context, index) {
                  final voyage = voyages[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.airplanemode_active,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            "${voyage['title']}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(Icons.category, voyage['type']),
                                const SizedBox(height: 4),
                                _buildInfoRow(
                                  Icons.description,
                                  voyage['description'],
                                ),
                                const SizedBox(height: 4),
                                _buildInfoRow(Icons.date_range, voyage['date']),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.price_change_sharp,
                                  "${voyage['price_per_person']} DH",
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${voyage['nbr_places']} places",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                  ),
                                  label: const Text("Accepter"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                      try {
                                        final response = await supabase
                                            .from('Voyage')
                                            .update({'status': 'accepted'})
                                            .eq('id', voyage['id'])
                                            .select(); // 💡 Important: Ensure updated result is returned

                                        if (response != null && response.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Voyage accepté')),
                                          );

                                          setState(() {
                                            voyages.removeAt(index); // ✅ Better than removeWhere
                                          });
                                        } else {
                                          throw Exception("Update failed or returned no result.");
                                        }
                                      } catch (error) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Erreur: $error')),
                                        );
                                      }
                                    },


                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel, size: 20),
                                  label: const Text("Rejeter"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                        try {
                                          final response = await supabase
                                              .from('Voyage')
                                              .update({'status': 'rejected'})
                                              .eq('id', voyage['id'])
                                              .select(); // 💡 Important: Ensure updated result is returned

                                          if (response != null && response.isNotEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Voyage rejeté')),
                                            );

                                            setState(() {
                                              voyages.removeAt(index);
                                            });
                                          } else {
                                            throw Exception("Update failed or returned no result.");
                                          }
                                        } catch (error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erreur: $error')),
                                          );
                                        }
                                      },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: Colors.blue.withOpacity(0.1),
            iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((
              states,
            ) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: Colors.blue);
              }
              return const IconThemeData(color: Colors.grey);
            }),
            labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
              states,
            ) {
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
            NavigationDestination(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
