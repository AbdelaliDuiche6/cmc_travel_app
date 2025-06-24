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

  String profilePictureUrl = ''; // To hold the profile image URL

  // Supabase project reference (use your actual project reference)
  final String baseUrl = "https://fhdtzxdrauwaimonbjkz.supabase.co/storage/v1/object/public/profile-images/";

  @override
  void initState() {
    super.initState();
    fetchReservations();
    _loadProfilePicture();
  }

  // Fetch reservations related to the current organizer
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
              id,
              title,
              image_url,
              description,
              date,
              price_per_person,
              free_places
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

  // Load profile picture from the database
  Future<void> _loadProfilePicture() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select('image_url')
          .eq('id', user.id)
          .single();

      final picturePath = response['image_url'];
      if (picturePath != null && picturePath.isNotEmpty) {
        String cleanPath =
            picturePath.startsWith('/')
                ? picturePath.substring(1)
                : picturePath;

        final profilePicUrl = supabase.storage
            .from('profile-images')
            .getPublicUrl(cleanPath);

        if (mounted) {
          setState(() {
            profilePictureUrl = profilePicUrl;
          });
        }
      }
    } catch (e) {
      print('Error loading profile picture: $e');
    }
  }

  // Build the stagiaire's avatar
  Widget _buildStagiaireAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Prepend base URL if the image URL is relative
      final fullImageUrl = imageUrl.startsWith('http')
          ? imageUrl // Already a full URL, no need to change
          : baseUrl + imageUrl;

      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          fullImageUrl,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading stagiaire image: $error');
            return Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.person, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(Icons.person, color: Colors.grey),
      );
    }
  }

  // Get the color for the payment status
  Color getPaymentColor(bool? state) {
    if (state == true) return Colors.green;
    if (state == false) return Colors.orange;
    return Colors.grey;
  }

  // Get the payment status text
  String getPaymentText(bool? state) {
    if (state == true) return '💳 Paid via Stripe';
    if (state == false) return '💵 Cash Payment';
    return '⏳ Pending';
  }

  // Build the status chip for payment state
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

  // Format the date
  String formatDate(String? dateString) {
    if (dateString == null) return "No date";
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date); // Only the date
    } catch (e) {
      return "Invalid date";
    }
  }

  // Confirm Cash Payment
  Future<void> confirmCashPayment(String id, Map<String, dynamic> trip) async {
    try {
      // Update the payment state of the reservation to 'true' (Stripe)
      await supabase
          .from('Reservation')
          .update({'payment_state': true})
          .eq('id', id);

      // Decrement the free places for the associated trip
      final tripId = trip['id'];
      final freePlaces = trip['free_places'];

      if (freePlaces != null && freePlaces > 0) {
        final updatedFreePlaces = freePlaces - 1;
        await supabase
            .from('Voyage')
            .update({'free_places': updatedFreePlaces})
            .eq('id', tripId);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Cash payment confirmed")),
      );
      fetchReservations(); // Reload reservations to reflect updates
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to confirm payment")),
      );
    }
  }

  // Build the UI for the reservations
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
                              trip['image_url'] ?? '',
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
                                // Stagiaire (User) Info
                                Row(
                                  children: [
                                    _buildStagiaireAvatar(profile?['image_url']),
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

                                // Show the confirm cash payment button
                                if (paymentState == false)
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        confirmCashPayment(res['id'], trip),
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Confirm Cash Payment",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 27, 222, 118),
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
