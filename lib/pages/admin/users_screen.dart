import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/statestique_screen.dart';
import 'package:cmc_travel_app/pages/admin/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
    final Color primaryColor = const Color(0xFF3AB796);
  final Color secondaryColor = const Color(0xFF3AABB7);
  final supabase = Supabase.instance.client;
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('profiles').select().inFilter(
        'role',
        ['organisateur', 'stagiaire'],
      );

      print('Fetched users: $response');

      setState(() {
        users = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  Future<void> toggleUserStatus(String userId, bool currentStatus) async {
    try {
      await supabase
          .from('profiles')
          .update({'is_active': !currentStatus})
          .eq('id', userId);

      fetchUsers(); // Refresh list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentStatus ? 'User banned' : 'User unbanned'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      print("eror: $e");
    }
  }

  int _selectedIndex = 1;
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
  Color _getRoleColor(String? role) {
  switch (role?.toLowerCase()) {
    case 'admin':
      return Colors.purple;
    case 'oragnisateur':
      return Colors.blue;
    case 'stagiaire':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users',
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.person,
          size: 28,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        user['name'] ?? 'Unnamed',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            user['phone_number'] ?? 'No phone',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getRoleColor(user['role']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Role: ${user['role']}',
              style: TextStyle(
                fontSize: 12,
                color: _getRoleColor(user['role']),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: user['is_active'] 
                ? Colors.red.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            user['is_active'] ? Icons.block : Icons.check_circle,
            color: user['is_active'] ? Colors.red : Colors.green,
            size: 20,
          ),
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                user['is_active'] ? 'Ban User' : 'Unban User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                user['is_active']
                    ? 'Are you sure you want to ban ${user['name'] ?? 'this user'}?'
                    : 'Do you want to unban ${user['name'] ?? 'this user'}?',
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
                TextButton(
                  child: Text(
                    user['is_active'] ? 'Confirm Ban' : 'Confirm Unban',
                    style: TextStyle(
                      color: user['is_active'] ? Colors.red : Colors.green,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await toggleUserStatus(user['id'], user['is_active']);
          }
        },
      ),
    ),
  ),
);
                },
              ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _navigate,
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.home, color: primaryColor),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.people, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.people, color: primaryColor),
              label: 'Utilisateurs',
            ),
            NavigationDestination(
              icon: Icon(Icons.stacked_bar_chart_rounded, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.stacked_bar_chart_rounded, color: primaryColor),
              label: 'Statestique',
            ),
            NavigationDestination(
              icon: Icon(Icons.person, color: Colors.grey[600]),
              selectedIcon: Icon(Icons.person, color: primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
