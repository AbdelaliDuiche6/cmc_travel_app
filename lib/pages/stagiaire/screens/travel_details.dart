import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cmc_travel_app/constants.dart';
import '../../../models/travel.dart';
import '../components/back_button.dart';
import '../shared/booking_status_notifier.dart';

class TravelDetails extends StatefulWidget {
  const TravelDetails({super.key, required this.travel});

  final Travel travel;
  @override
  State<TravelDetails> createState() => _TravelDetailsState();
}

class _TravelDetailsState extends State<TravelDetails> {
  final supabase = Supabase.instance.client;
  bool isBookedByCurrentUser = false;
  String? organizerPhone;

  @override
  void initState() {
    super.initState();
    checkIfUserBooked();

    BookingStatusNotifier.voyageBookingStatus.addListener(() {
      final status =
          BookingStatusNotifier.voyageBookingStatus.value[widget.travel.id];
      if (status == false) {
        setState(() {
          isBookedByCurrentUser = false;
        });
      }
    });
  }

  Future<void> checkIfUserBooked() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final booking =
        await supabase
            .from('Reservation')
            .select('status')
            .eq('stagiaire_id', userId)
            .eq('voyage_id', widget.travel.id)
            .not('status', 'in', ['Canceled', 'Completed'])
            .maybeSingle();

    setState(() {
      isBookedByCurrentUser = booking != null;
    });

    // debugPrint('[TravelDetails] Booking check result: $booking');
  }

  void _showFlushbar(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.black87,
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 500),
      icon: Icon(Icons.info_outline, color: Colors.white),
    ).show(context);
  }

  Future<bool> isUserAlreadyBooked(String voyageId) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return false;

    final response =
        await supabase
            .from('Reservation')
            .select('id, status')
            .eq('voyage_id', voyageId)
            .eq('stagiaire_id', userId)
            .maybeSingle();

    if (response == null ||
        response['status'] == 'Canceled' ||
        response['status'] == 'Completed') {
      return false; // User did not book or has canceled or its completed
    }

    return true; // Reservation exists and not canceled and not completed
  }

  Future<void> _insertReservation(bool paymentState) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final existing = await supabase
        .from('Reservation')
        .select()
        .eq('voyage_id', widget.travel.id)
        .eq('stagiaire_id', userId);

    if (existing.isNotEmpty) {
      Navigator.pop(context);
      _showFlushbar('You already booked this trip!');
      return;
    }
    try {
      await supabase.from('Reservation').insert({
        'stagiaire_id': userId,
        'voyage_id': widget.travel.id,
        'payment_state': paymentState,
        'organizer_id': widget.travel.organizerId,
      });

      setState(() {
        isBookedByCurrentUser = true;
      });

      if (paymentState) {
        // Stripe only
        await supabase
            .from('Voyage')
            .update({'free_places': widget.travel.freePlaces - 1})
            .eq('id', widget.travel.id);

        setState(() {
          widget.travel.freePlaces--;
        });
      }

      if (!mounted) return;

      Navigator.pop(context);
      _showFlushbar('Reservation created successfully!');
    } catch (e) {
      if (!mounted) return;
      _showFlushbar('Error creating reservation: ${e.toString()}');
    }
  }

  /// Fetch the organizer's phone number from Supabase
  Future<void> fetchOrganizerPhone() async {
    final response =
        await supabase
            .from('profiles')
            .select('phone_number')
            .eq('id', widget.travel.organizerId)
            .maybeSingle();

    setState(() {
      organizerPhone = response != null ? response['phone_number'] : null;
    });
  }

  void _openPaymentOverlay() {
    int? selectedPayment;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setModalState) => Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Payment  Method',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.withAlpha(30),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: kDefaultPadding,
                                  right: kDefaultPadding,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/stripe.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Stripe',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Spacer(),
                                    Radio(
                                      value: 1,
                                      groupValue: selectedPayment,
                                      onChanged: (value) {
                                        setModalState(
                                          () => selectedPayment = value as int,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: kDefaultPadding,
                                  right: kDefaultPadding,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on_rounded,
                                      size: 30,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Cash',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Spacer(),
                                    Radio(
                                      value: 2,
                                      groupValue: selectedPayment,
                                      onChanged: (value) {
                                        setModalState(
                                          () => selectedPayment = value as int,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (selectedPayment == null) {
                              _showFlushbar('Please select a payment method!');
                              return;
                            }
                            _insertReservation(selectedPayment == 1);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: kDefaultPadding * 1.5,
                              vertical: kDefaultPadding / 2,
                            ),
                          ),
                          child: Text(
                            'Pay',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'd MMM yyyy',
    ).format(widget.travel.date);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 60,
                            color: Colors.black.withAlpha(150),
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Image.network(
                        widget.travel.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(Icons.image),
                      ),
                    ),
                  ),
                  CustomBackButton(
                    backgroundColor: Colors.white,
                    onTap: () => {Navigator.of(context).pop()},
                    margin: EdgeInsets.only(top: 35, left: 20),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.travel.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: kPrimaryColor.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _travelInfo('via', widget.travel.organizerName),
                    _travelInfo('type', widget.travel.type),
                    _travelInfo(
                      'free seats',
                      widget.travel.freePlaces.toString(),
                    ),
                    _travelInfo('seats', widget.travel.places.toString()),
                  ],
                ),
              ),
              Divider(
                color: Colors.black.withAlpha(70),
                thickness: 1.5,
                indent: 40,
                endIndent: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: kDefaultPadding),
                child: Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: kDefaultPadding / 2,
                  left: kDefaultPadding,
                  right: kDefaultPadding,
                ),
                child: Text(widget.travel.description),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: kDefaultPadding / 2,
                      left: kDefaultPadding,
                    ),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(
                      top: kDefaultPadding / 2,
                      left: kDefaultPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withAlpha(70),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(color: Colors.black.withAlpha(150)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${widget.travel.price}/',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        TextSpan(
                          text: 'Person',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withAlpha(90),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  // if() buildOrganizerContactMessage(),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed:
                        widget.travel.freePlaces == 0 || isBookedByCurrentUser
                            ? null
                            : _openPaymentOverlay,
                    style: TextButton.styleFrom(
                      backgroundColor:
                          isBookedByCurrentUser ? Colors.grey : kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 1.5,
                        vertical: kDefaultPadding / 2,
                      ),
                    ),
                    child: Text(
                      isBookedByCurrentUser ? 'Booked' : 'Book Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Column _travelInfo(String label, String content) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.black.withAlpha(70),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Show organizer contact info when booked via Cash
  Widget buildOrganizerContactMessage() {
    if (!isBookedByCurrentUser || organizerPhone == null)
      return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 10,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '💬 Contact the organizer to confirm your trip:\n📞 $organizerPhone',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
