import 'package:cmc_travel_app/pages/organizer/org_add_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_detail_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_edit_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_profile_page.dart';
import 'package:cmc_travel_app/pages/organizer/org_trip_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class OrgHomePage extends StatefulWidget {
  const OrgHomePage({super.key});

  @override
  State<OrgHomePage> createState() => _OrgHomePageState();
}

class _OrgHomePageState extends State<OrgHomePage> {
  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> trips = [];
  List<Map<String, dynamic>> filteredTrips = [];

  bool isLoading = true;
  bool isRefreshing = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String profilePictureUrl = '';
  int pendingBookingsCount = 0;

  StreamSubscription<List<Map<String, dynamic>>>? _tripsSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchTrips();
    _loadProfilePicture();
    _loadPendingBookingsCount();
    _setupRealTimeUpdates();
    _setupPeriodicRefresh();
  }

  @override
  void dispose() {
    _tripsSubscription?.cancel();
    _refreshTimer?.cancel();
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupRealTimeUpdates() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _tripsSubscription = supabase
        .from('Voyage')
        .stream(primaryKey: ['id'])
        .eq('organizer_id', user.id)
        .listen((data) {
          if (mounted) {
            setState(() {
              trips = data.map((e) => e as Map<String, dynamic>).toList();
              trips.sort((a, b) {
                final dateA =
                    DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
                final dateB =
                    DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
                return dateB.compareTo(dateA);
              });
              _filterTrips();
            });
          }
        });
  }

  void _setupPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  void _filterTrips() {
    if (searchQuery.isEmpty) {
      filteredTrips = trips;
    } else {
      filteredTrips =
          trips.where((trip) {
            final title = trip['title']?.toString().toLowerCase() ?? '';
            return title.contains(searchQuery);
          }).toList();
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() {
      isRefreshing = true;
    });

    await Future.wait([
      fetchTrips(),
      _loadProfilePicture(),
      _loadPendingBookingsCount(),
    ]);

    if (mounted) {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  bool _isTripEditable(String status) {
  final normalizedStatus = status.toLowerCase();
  return normalizedStatus == 'false' || 
         normalizedStatus == 'pending' || 
         normalizedStatus == 'rejected';
}

  Map<String, dynamic> _getStatusInfo(String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus == 'accepted') {
      return {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'text': 'Accepted',
        'description': 'Trip accepted by admin',
      };
    } else if (normalizedStatus == 'rejected') {
      return {
        'color': Colors.red,
        'icon': Icons.cancel,
        'text': 'Rejected',
        'description': 'Trip rejected by admin',
      };
    } else {
      return {
        'color': Colors.orange,
        'icon': Icons.pending,
        'text': 'Pending',
        'description': 'Waiting for admin approval',
      };
    }
  }

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
          Icon(statusInfo['icon'], size: 14, color: statusInfo['color']),
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

  Future<void> _loadPendingBookingsCount() async {
  try {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('Reservation')
        .select('id, payment_state')
        .eq('organizer_id', user.id)
        .eq('payment_state', false);

    if (mounted) {
      setState(() {
        pendingBookingsCount = response.length;
      });
    }
  } catch (e) {
    print('Error loading pending reservation count: $e');
  }
}


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

      if (mounted) {
        setState(() {
          trips = data.map((e) => e as Map<String, dynamic>).toList();
          _filterTrips();
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching trips: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteTrip(dynamic id) async {
    try {
      print('Deleting trip with id: $id, type: ${id.runtimeType}');

      final tripResponse =
          await supabase
              .from('Voyage')
              .select('image_url')
              .eq('id', id)
              .single();

      final imageUrl = tripResponse['image_url'] as String?;

      final response =
          await supabase.from('Voyage').delete().eq('id', id).select();

      print('Delete response: $response');

      if ((response.isEmpty)) {
        throw Exception('No trip deleted, check the id and query');
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          String imagePath;

          if (imageUrl.startsWith('http')) {
            final uri = Uri.parse(imageUrl);
            final pathSegments = uri.pathSegments;
            final bucketIndex = pathSegments.indexOf('storage');
            if (bucketIndex != -1 && bucketIndex + 3 < pathSegments.length) {
              final bucketName = pathSegments[bucketIndex + 4];
              imagePath = pathSegments.sublist(bucketIndex + 5).join('/');
            } else {
              throw Exception('Could not parse image URL path');
            }
          } else {
            imagePath =
                imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
          }

          print('Attempting to delete image at path: $imagePath');

          final storageResponse = await supabase.storage
              .from('trip-images')
              .remove([imagePath]);

          print('Storage delete response: $storageResponse');
        } catch (storageError) {
          print('Error deleting image from storage: $storageError');
        }
      }

      if (mounted) {
        setState(() {
          trips.removeWhere((trip) => trip['id'] == id);
          _filterTrips();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Trip and associated image deleted successfully"),
          ),
        );
      }
    } catch (e) {
      print('Error deleting trip: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete trip: ${e.toString()}")),

        );
      }
    }
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      _filterTrips();
    });
  }

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

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final status = trip['status'] ?? 'en_cours';
    final statusInfo = _getStatusInfo(status);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripDetailsPage(trip: trip)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.only(bottom: 15),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: trip['image_url'] != null
                        ? Image.network(
                            trip['image_url'],
                            fit: BoxFit.cover,
                            loadingBuilder: (
                              context,
                              child,
                              loadingProgress,
                            ) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.broken_image, size: 50),
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
                Positioned(top: 10, right: 10, child: _buildStatusChip(status)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            ).format(DateTime.parse(trip['date']))
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
                        '${trip['price_per_person']?.toStringAsFixed(2) ?? '-'} \MAD ',
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16),
                      SizedBox(width: 5),
                      Text('${trip['nbr_places'] ?? '-'} seats'),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            _isTripEditable(status)
                                ? () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditTripPage(trip: trip),
                                      ),
                                    );
                                    if (result == true) fetchTrips();
                                  }
                                : null,
                        icon: Icon(Icons.edit, size: 18),
                        label: Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isTripEditable(status)
                                  ? Colors.blue
                                  : Colors.grey,
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
                                  title: Text("Confirm Delete"),
                                  content: Text(
                                    "Are you sure you want to delete this trip? This action cannot be undone.",
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteTrip(trip['id']);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.blue[200],
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Image.asset(
                      "assets/images/backgroundImg.jpg",
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2.5,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrgReservationsPage(),
                        ),
                      ).then((_) {
                        _loadPendingBookingsCount();
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
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddTripPage()),
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
                        child: Icon(Icons.add, color: Colors.black, size: 30.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrgProfilePage(),
                        ),
                      ).then((_) => _loadProfilePicture());
                    },
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(60),
                      child: _buildProfileAvatar(),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(70),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                    left: 20.0,
                    right: 20.0,
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
              ),
            ),

            if (isLoading)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredTrips.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No trips found'),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final trip = filteredTrips[index];
                    return _buildTripCard(trip);
                  }, childCount: filteredTrips.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
