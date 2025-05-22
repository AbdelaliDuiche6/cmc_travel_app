import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'org_modify_page.dart';

class OrgProfilePage extends StatefulWidget {
  @override
  _OrgProfilePageState createState() => _OrgProfilePageState();
}

class _OrgProfilePageState extends State<OrgProfilePage> {
  String name = '';
  String email = '';
  String phone = '';
  String createdAt = '';
  int tripCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final userId = user.id;
    final userEmail = user.email ?? '';
    final createdAtRaw = user.createdAt;
    DateTime? createdDate = createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
    String createdDateFormatted = createdDate != null ? createdDate.toLocal().toString().split(" ").first : '';

    try {
      // Get profile info
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Count trips
      final tripResponse = await Supabase.instance.client
          .from('Voyage')
          .select()
          .eq('organizer_id', userId);

      setState(() {
        name = profileResponse['name'] ?? 'Unknown';
        phone = profileResponse['phone_number'] ?? 'N/A';
        email = userEmail;
        createdAt = createdDateFormatted;
        tripCount = tripResponse.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Organizer Profile"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.push(context , MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: AssetImage("Images/pfp.jpg"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("Role: Organizer", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.email, email),
                          Divider(),
                          _buildInfoRow(Icons.phone, phone),
                          Divider(),
                          _buildInfoRow(Icons.directions_car, "$tripCount Trips"),
                          Divider(),
                          _buildInfoRow(Icons.calendar_today, createdAt),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrgModifyPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
