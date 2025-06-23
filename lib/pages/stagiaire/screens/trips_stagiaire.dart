import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../constants.dart';
import '../widgets/my_trip_card.dart';

class TripsStagiaire extends StatefulWidget {
  const TripsStagiaire({super.key});

  @override
  State<TripsStagiaire> createState() => _TripsStagiaireState();
}

class _TripsStagiaireState extends State<TripsStagiaire> {
  final supabase = Supabase.instance.client;
  List<dynamic> reservations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('Reservation')
          .select('*, Voyage(*, profiles(name))')
          .eq('stagiaire_id', userId);

      setState(() {
        reservations = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching reservations';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'My trips',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator(color: kPrimaryColor,),)
      : errorMessage != null 
      ? Center(child: Text(errorMessage!))
      : reservations.isEmpty
      ?Center(child: Text('No reservations yet!'))
      : ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        final voyage = reservation['Voyage'];
                        final organizerName = voyage['profiles']['name'];

                        return MyTripCard(
                          title: voyage['title'],
                          date: voyage['date'],
                          type: voyage['type'],
                          organizer: organizerName,
                          price: voyage['price_per_person'].toString(),
                          imageUrl: voyage['image_url'],
                          status: reservation['status'],
                        );
                      },
                    ),

          
                             
    );
  }

  Widget _button(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
