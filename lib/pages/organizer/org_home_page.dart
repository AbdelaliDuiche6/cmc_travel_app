import 'package:cmc_travel_app/pages/organizer/org_add_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_detail_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_edit_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_profile_page.dart';
import 'package:cmc_travel_app/pages/organizer/org_trip_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class OrgHomePage extends StatefulWidget {
  const OrgHomePage({super.key});

  @override
  State<OrgHomePage> createState() => _OrgHomePageState();
}

class _OrgHomePageState extends State<OrgHomePage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> trips = [];
  List<Map<String, dynamic>> filteredTrips = [];

  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  String profilePictureUrl = ''; // Add this to store profile picture URL
  int pendingBookingsCount = 0; // Add this to track pending bookings

  @override
  void initState() {
    super.initState();
    fetchTrips();
    _loadProfilePicture(); // Add this to load profile picture
    _loadPendingBookingsCount(); // Add this to load pending bookings count
  }

  // Simplified helper method to check if trip is approved
bool _isTripApproved(String status) {
  final normalizedStatus = status.toLowerCase();
  return normalizedStatus == 'accepted'; // Only 'accepted' is considered approved
}

// Simplified method to get status color and icon
Map<String, dynamic> _getStatusInfo(String status) {
  final normalizedStatus = status.toLowerCase();
  
  if (normalizedStatus == 'accepted') {
    return {
      'color': Colors.green,
      'icon': Icons.check_circle,
      'text': 'Accepted',
      'description': 'Trip accepted by admin'
    };
  } else if (normalizedStatus == 'rejected') {
    return {
      'color': Colors.red,
      'icon': Icons.cancel,
      'text': 'Rejected',
      'description': 'Trip rejected by admin'
    };
  } else {
    // All other statuses (including 'en_cours', 'pending', etc.) will be treated as pending
    return {
      'color': Colors.orange,
      'icon': Icons.pending,
      'text': 'Pending',
      'description': 'Waiting for admin approval'
    };
  }
}

// Status chip remains the same as it uses _getStatusInfo
Widget _buildStatusChip(String status) {
  final statusInfo = _getStatusInfo(status);
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: statusInfo['color'].withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusInfo['color'], width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          statusInfo['icon'],
          size: 14,
          color: statusInfo['color'],
        ),
        SizedBox(width: 4),
        Text(
          statusInfo['text'],
          style: TextStyle(
            color: statusInfo['color'],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

  // Add this method to load pending bookings count
  Future<void> _loadPendingBookingsCount() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('bookings') // Adjust table name as needed
          .select('id')
          .eq('organizer_id', user.id)
          .eq('status', 'pending'); // Assuming 'pending' is the status for unconfirmed bookings

      setState(() {
        pendingBookingsCount = response.length;
      });
    } catch (e) {
      print('Error loading pending bookings count: $e');
    }
  }

  // Add this method to load the profile picture
  Future<void> _loadProfilePicture() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response =
          await supabase
              .from('profiles')
              .select('image_url')
              .eq('id', user.id)
              .single();

      final picturePath = response['image_url'];
      if (picturePath != null && picturePath.isNotEmpty) {
        // Clean the path - remove leading slash if present
        String cleanPath =
            picturePath.startsWith('/')
                ? picturePath.substring(1)
                : picturePath;

        final profilePicUrl = supabase.storage
            .from('profile-images')
            .getPublicUrl(cleanPath);

        setState(() {
          profilePictureUrl = profilePicUrl;
        });
      }
    } catch (e) {
      print('Error loading profile picture: $e');
    }
  }

  Future<void> fetchTrips() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      final response = await supabase
          .from('Voyage')
          .select()
          .eq('organizer_id', user.id)
          .order('date', ascending: false);

      final data = response as List<dynamic>;

      setState(() {
        trips = data.map((e) => e as Map<String, dynamic>).toList();
        filteredTrips = trips;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching trips: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteTrip(dynamic id) async {
  try {
    print('Deleting trip with id: $id, type: ${id.runtimeType}');

    // First, get the trip data to find the image URL
    final tripResponse = await supabase
        .from('Voyage')
        .select('image_url')
        .eq('id', id)
        .single();

    final imageUrl = tripResponse['image_url'] as String?;
    
    // Delete the trip from database
    final response = await supabase
        .from('Voyage')
        .delete()
        .eq('id', id)
        .select();

    print('Delete response: $response');

    if (response == null || (response is List && response.isEmpty)) {
      throw Exception('No trip deleted, check the id and query');
    }

    // If trip has an image, delete it from storage
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        // Extract the file path from the image URL
        // Assuming the image_url is stored as a path like 'trip-images/filename.jpg'
        // or a full URL that needs to be parsed
        String imagePath;
        
        if (imageUrl.startsWith('http')) {
          // If it's a full URL, extract the path
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          // Find the bucket name and file path
          final bucketIndex = pathSegments.indexOf('storage');
          if (bucketIndex != -1 && bucketIndex + 3 < pathSegments.length) {
            // Path structure: /storage/v1/object/public/bucket-name/file-path
            final bucketName = pathSegments[bucketIndex + 4];
            imagePath = pathSegments.sublist(bucketIndex + 5).join('/');
          } else {
            throw Exception('Could not parse image URL path');
          }
        } else {
          // If it's already a path, use it directly
          imagePath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
        }

        print('Attempting to delete image at path: $imagePath');

        // Delete from storage bucket (adjust bucket name as needed)
        final storageResponse = await supabase.storage
            .from('trip-images') // Replace with your actual bucket name
            .remove([imagePath]);

        print('Storage delete response: $storageResponse');
        
      } catch (storageError) {
        print('Error deleting image from storage: $storageError');
        // Don't throw here - we still want to update the UI even if image deletion fails
      }
    }

    // Update the local state
    setState(() {
      trips.removeWhere((trip) => trip['id'] == id);
      filteredTrips.removeWhere((trip) => trip['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Trip and associated image deleted successfully"))
    );
    
  } catch (e) {
    print('Error deleting trip: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to delete trip: ${e.toString()}"))
    );
  }
}

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredTrips =
          trips.where((trip) {
            final title = trip['title']?.toString().toLowerCase() ?? '';
            return title.contains(searchQuery);
          }).toList();
    });
  }

  // Add this method to build the profile avatar
  Widget _buildProfileAvatar() {
    if (profilePictureUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          profilePictureUrl,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            return Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(60),
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
          borderRadius: BorderRadius.circular(60),
        ),
        child: Icon(Icons.person, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/images/image.png",
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Booking Confirmations Button (NEW)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrgTripConfirmatino(),
                          ),
                        ).then((_) {
                          _loadPendingBookingsCount(); // Refresh count when returning
                        });
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: Colors.black,
                                size: 30.0,
                              ),
                              if (pendingBookingsCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$pendingBookingsCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    // Add Trip Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTripPage(),
                          ),
                        ).then((_) => fetchTrips());
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.0),
                    // Profile Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrgProfilePage(),
                          ),
                        ).then(
                          (_) => _loadProfilePicture(),
                        ); // Reload profile picture when returning
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(60),
                        child:
                            _buildProfileAvatar(), // Use the new method instead of hardcoded image
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 210.0, left: 20.0),
                child: Text(
                  "CMC TRAVEL",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: MediaQuery.of(context).size.height / 2.7,
                ),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: updateSearch,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search your destination",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        suffixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child:
                  filteredTrips.isEmpty
                      ? Center(child: Text('No trips found'))
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          final status = trip['status'] ?? 'en_cours';
                          final statusInfo = _getStatusInfo(status);
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetailsPage(trip: trip),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.only(bottom: 15),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Container with Status Badge
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Container(
                                          height: 150,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child:
                                              trip['image_url'] != null
                                                  ? Image.network(
                                                    trip['image_url'],
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress == null)
                                                        return child;
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          value:
                                                              loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                  : Center(
                                                    child: Icon(
                                                      Icons.photo,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      // Status Badge positioned on top-right of image
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: _buildStatusChip(status),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Status Info Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                trip['title'] ?? 'No Title',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Tooltip(
                                              message: statusInfo['description'],
                                              child: Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 16),
                                            SizedBox(width: 5),
                                            Text(
                                              trip['date'] != null
                                                  ? DateFormat(
                                                    'MMM dd, yyyy',
                                                  ).format(
                                                    DateTime.parse(trip['date']),
                                                  )
                                                  : '-',
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(Icons.attach_money, size: 16),
                                            SizedBox(width: 5),
                                            Text(
                                              '\$${trip['price_per_person']?.toStringAsFixed(2) ?? '-'}',
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(Icons.people, size: 16),
                                            SizedBox(width: 5),
                                            Text(
                                              '${trip['free_places'] ?? '-'}/${trip['nbr_places'] ?? '-'} seats left',
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // CORRECTED EDIT BUTTON
                                            ElevatedButton.icon(
                                              onPressed: _isTripApproved(status) ? () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditTripPage(trip: trip),
                                                  ),
                                                );
                                                if (result == true) fetchTrips();
                                              } : null,
                                              icon: Icon(Icons.edit, size: 18),
                                              label: Text("Edit"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _isTripApproved(status) ? Colors.blue : Colors.grey,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (context) => AlertDialog(
                                                        title: Text(
                                                          "Confirm Delete",
                                                        ),
                                                        content: Text(
                                                          "Are you sure you want to delete this trip? This action cannot be undone.",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: Text("Cancel"),
                                                            onPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                color: Colors.red,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              deleteTrip(
                                                                trip['id'],
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              },
                                              icon: Icon(Icons.delete, size: 18),
                                              label: Text("Delete"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                elevation: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
        ],
      ),
    );
  }
}