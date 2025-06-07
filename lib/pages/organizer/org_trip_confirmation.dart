import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class OrgTripConfirmatino extends StatefulWidget {
  const OrgTripConfirmatino({super.key});

  @override
  State<OrgTripConfirmatino> createState() => _OrgTripConfirmatino();
}

class _OrgTripConfirmatino extends State<OrgTripConfirmatino> {
  final supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> pendingBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingBookings();
  }

  Future<void> fetchPendingBookings() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      // Adjust this query based on your database schema
      final response = await supabase
          .from('bookings')
          .select('''
            id,
            stagiaire_id,
            trip_id,
            status,
            created_at,
            profiles!stagiaire_id (
              full_name,
              email,
              image_url
            ),
            Voyage!trip_id (
              title,
              date,
              price_per_person
            )
          ''')
          .eq('organizer_id', user.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        pendingBookings = (response as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching pending bookings: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      await supabase
          .from('bookings')
          .update({'status': 'confirmed'})
          .eq('id', bookingId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking confirmed successfully")),
      );

      // Refresh the list
      fetchPendingBookings();
    } catch (e) {
      print('Error confirming booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to confirm booking: ${e.toString()}")),
      );
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await supabase
          .from('bookings')
          .update({'status': 'rejected'})
          .eq('id', bookingId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking rejected")),
      );

      // Refresh the list
      fetchPendingBookings();
    } catch (e) {
      print('Error rejecting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject booking: ${e.toString()}")),
      );
    }
  }

  Widget _buildStagiaireAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          imageUrl,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(Icons.person, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(Icons.person, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pendingBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No pending bookings',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: pendingBookings.length,
                  itemBuilder: (context, index) {
                    final booking = pendingBookings[index];
                    final stagiaire = booking['profiles'];
                    final trip = booking['Voyage'];
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stagiaire Info
                            Row(
                              children: [
                                _buildStagiaireAvatar(stagiaire?['image_url']),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stagiaire?['full_name'] ?? 'Unknown User',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        stagiaire?['email'] ?? '',
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
                            SizedBox(height: 12),
                            Divider(),
                            SizedBox(height: 8),
                            
                            // Trip Info
                            Text(
                              'Trip: ${trip?['title'] ?? 'Unknown Trip'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  trip?['date'] != null
                                      ? DateFormat('MMM dd, yyyy').format(
                                          DateTime.parse(trip['date']),
                                        )
                                      : 'Date not available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  '\$${trip?['price_per_person']?.toString() ?? '0.00'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  'Requested: ${DateFormat('MMM dd, yyyy - HH:mm').format(
                                    DateTime.parse(booking['created_at']),
                                  )}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Reject Booking"),
                                        content: Text(
                                          "Are you sure you want to reject this booking request?",
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text(
                                              "Reject",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              rejectBooking(booking['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.close, color: Colors.red),
                                  label: Text(
                                    "Reject",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Confirm Booking"),
                                        content: Text(
                                          "Are you sure you want to confirm this booking request?",
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(color: Colors.green),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              confirmBooking(booking['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.check, color: Colors.white),
                                  label: Text("Confirm"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}