import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TripDetailsPage extends StatefulWidget {
  final Map<String, dynamic> trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final supabase = Supabase.instance.client;
  String organizerName = '';
  String organizerImageUrl = '';
  bool isLoadingOrganizer = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizerInfo();
  }

  Future<void> _loadOrganizerInfo() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('name, image_url')
          .eq('id', widget.trip['organizer_id'])
          .single();

      String finalProfilePicUrl = '';
      final picturePath = response['image_url'];

      if (picturePath != null && picturePath.isNotEmpty) {
        finalProfilePicUrl = supabase.storage
            .from('profile-images')
            .getPublicUrl(picturePath);
      }

      setState(() {
        organizerName = response['name'] ?? 'Unknown Organizer';
        organizerImageUrl = finalProfilePicUrl;
        isLoadingOrganizer = false;
      });
    } catch (e) {
      print('Error loading organizer info: $e');
      setState(() {
        organizerName = 'Unknown Organizer';
        isLoadingOrganizer = false;
      });
    }
  }

  Widget _buildOrganizerAvatar() {
    const double size = 60;

    if (organizerImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          organizerImageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: Icon(Icons.person, size: 30, color: Colors.grey),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.person, size: 30, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: widget.trip['image_url'] != null
                    ? Image.network(
                        widget.trip['image_url'],
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
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.photo,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.white),
          ),

          // Trip Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Title
                  Text(
                    widget.trip['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),

                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    content: widget.trip['date'] != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(
                            DateTime.parse(widget.trip['date']),
                          )
                        : 'Date not specified',
                  ),

                  _buildInfoCard(
                    icon: Icons.attach_money,
                    title: 'Price per Person',
                    content: widget.trip['price_per_person'] != null
                        ? '\$${widget.trip['price_per_person'].toStringAsFixed(2)}'
                        : 'Price not specified',
                  ),

                  _buildInfoCard(
                    icon: Icons.people,
                    title: 'Available Seats',
                    content:
                        '${widget.trip['free_places'] ?? 0} out of ${widget.trip['nbr_places'] ?? 0} seats available',
                  ),

                  // Organizer info with square image
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildOrganizerAvatar(),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Organizer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                isLoadingOrganizer
                                    ? 'Loading...'
                                    : organizerName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description
                  if (widget.trip['description'] != null &&
                      widget.trip['description'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description,
                                  color: Colors.blue, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            widget.trip['description'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 30),

                  // Book Now Button
                  if (widget.trip['free_places'] != null &&
                      widget.trip['free_places'] > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking functionality to be implemented'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (widget.trip['free_places'] == null ||
                      widget.trip['free_places'] <= 0)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Fully Booked',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
