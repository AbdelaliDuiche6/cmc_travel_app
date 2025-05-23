import 'package:cmc_travel_app/pages/organizer/org_add_trip.dart';
import 'package:cmc_travel_app/pages/organizer/org_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    fetchTrips();
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
          .order('date', ascending: true);

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
    // id is dynamic, could be String or int depending on DB schema
    try {
      print('Deleting trip with id: $id, type: ${id.runtimeType}');

      // Adjust this if your id in DB is integer, parse accordingly:
      // final deleteId = (id is String) ? int.tryParse(id) ?? id : id;

      final response = await supabase
          .from('Voyage')
          .delete()
          .eq('id', id)
          .select(); // Use select() to get deleted rows back

      print('Delete response: $response');

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No trip deleted, check the id and query');
      }

      setState(() {
        trips.removeWhere((trip) => trip['id'] == id);
        filteredTrips.removeWhere((trip) => trip['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trip deleted successfully")),
      );
    } catch (e) {
      print('Error deleting trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete trip")),
      );
    }
  }

  void updateSearch(String query) {
    setState(() { 
      searchQuery = query.toLowerCase();
      filteredTrips = trips.where((trip) {
        final title = trip['title']?.toString().toLowerCase() ?? '';
        return title.contains(searchQuery);
      }).toList();
    });
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
                    GestureDetector(
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
                    SizedBox(width: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrgProfilePage()),
                        );
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset(
                            "assets/images/pfp.jpg",
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
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
            Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: filteredTrips.isEmpty
                  ? Center(child: Text('No trips found'))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = filteredTrips[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 15),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip['title'] ?? 'No Title',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Date: ${trip['date'] ?? '-'}\nPrice: \$${trip['price_per_person'] ?? '-'}",
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // TODO: Navigate to EditTripPage
                                        print("Edit trip ${trip['id']}");
                                      },
                                      icon: Icon(Icons.edit, size: 18),
                                      label: Text("Edit"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Confirm Delete"),
                                            content: Text("Are you sure you want to delete this trip?"),
                                            actions: [
                                              TextButton(
                                                child: Text("Cancel"),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                              TextButton(
                                                child: Text("Delete", style: TextStyle(color: Colors.red)),
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
            ),
        ],
      ),
    );
  }
}
