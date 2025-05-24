import 'package:cmc_travel_app/pages/login_screen.dart';
import 'package:cmc_travel_app/pages/organizer/org_modify_page.dart';
import 'package:cmc_travel_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cmc_travel_app/pages/organizer/org_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage("Images/pfp.jpg") as ImageProvider,
            ),
            SizedBox(height: 20),
            Text(
              "My Organize",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Role: Organize", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),

            // Using Card for user info
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.email, "myorganize@gmail.com"),
                    Divider(),
                    _buildInfoRow(Icons.phone, "+21263132534"),
                    Divider(),
                    _buildInfoRow(Icons.directions_car, "30 Trips"),
                    Divider(),
                    _buildInfoRow(Icons.calendar_today, "22/05/2025"),
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
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("Edit Profile"),
            ),
          ],
        ),
      ),
    );
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
}