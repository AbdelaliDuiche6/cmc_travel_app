import 'package:cmc_travel_app/pages/admin/admin_screen.dart';
import 'package:cmc_travel_app/pages/admin/notification_screen.dart';
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
  title: Center(
    child: const Text(
      'Users',
      style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.white,
        fontFamily: 'Poppins', // Ou 'Montserrat' si préféré
      ),
    ),
  ),
  
  centerTitle: true,
  backgroundColor: const Color.fromARGB(255, 58, 183, 162), // Ou Colors.indigo[800]
  elevation: 8,
  shadowColor: const Color.fromARGB(255, 58, 183, 171).withOpacity(0.5),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(15),
    ),
  ),
  toolbarHeight: 70,
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications, size: 26),
      onPressed: () {},
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
