import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For formatting date

class OrgReservationsPage extends StatefulWidget {
  const OrgReservationsPage({super.key});

  @override
  State<OrgReservationsPage> createState() => _OrgReservationsPageState();
}

class _OrgReservationsPageState extends State<OrgReservationsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('Reservation')
          .select('''
            id,
            payment_state,
            organizer_id,
            profiles:stagiaire_id (
              name,
              image_url
            ),
            Voyage:voyage_id (
              title,
              image_url,
              description,
              date,
              price_per_person
            )
          ''')
          .eq('organizer_id', user.id);

      setState(() {
        reservations = (response as List).cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      print("Error while loading reservations: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> confirmCashPayment(String id) async {
    try {
      await supabase
          .from('Reservation')
          .update({'payment_state': true})
          .eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Cash payment confirmed")),
      );
      fetchReservations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to confirm payment")),
      );
    }
  }

  Color getPaymentColor(bool? state) {
    if (state == true) return Colors.green;
    if (state == false) return Colors.orange;
    return Colors.grey;
  }

  String getPaymentText(bool? state) {
    if (state == true) return '💳 Paid via Stripe';
    if (state == false) return '💵 Cash Payment';
    return '⏳ Pending';
  }

  Widget buildStatusChip(bool? state) {
    final color = getPaymentColor(state);
    final text = getPaymentText(state);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String formatDate(String? dateString) {
  if (dateString == null) return "No date";
  try {
    final date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(date); // Only the date
  } catch (e) {
    return "Invalid date";
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Reservations"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? Center(child: Text("No reservations found"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final res = reservations[index];
                    final profile = res['profiles'];
                    final trip = res['Voyage'];
                    final paymentState = res['payment_state'] as bool?;
                    final image = trip['image_url'];

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip Image
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.network(
                              image ?? '',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: Icon(Icons.image, size: 40),
                              ),
                            ),
                          ),

                          // Trip Info
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: profile?['image_url'] !=
                                              null
                                          ? NetworkImage(profile['image_url'])
                                          : null,
                                      child: profile?['image_url'] == null
                                          ? Icon(Icons.person)
                                          : null,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        profile?['name'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Trip title
                                Text(
                                  trip['title'] ?? 'No title',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),

                                // Trip description
                                if (trip['description'] != null)
                                  Text(
                                    trip['description'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                SizedBox(height: 6),

                                // Trip date
                                if (trip['date'] != null)
                                  Text(
                                    "📅 ${formatDate(trip['date'])}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                SizedBox(height: 6),

                                // Trip price
                                if (trip['price_per_person'] != null)
                                  Text(
                                    "💰 ${trip['price_per_person']} MAD",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                SizedBox(height: 10),

                                // Payment status
                                buildStatusChip(paymentState),
                                SizedBox(height: 10),

                                // Confirm Cash button
                                if (paymentState == false)
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        confirmCashPayment(res['id']),
                                    icon: Icon(Icons.check),
                                    label: Text("Confirm Payment"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
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
    );
  }
}
