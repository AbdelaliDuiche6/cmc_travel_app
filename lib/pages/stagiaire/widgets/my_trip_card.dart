// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:another_flushbar/flushbar.dart';
import 'package:cmc_travel_app/models/travel.dart';
import 'package:cmc_travel_app/pages/stagiaire/screens/travel_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cmc_travel_app/constants.dart';

import '../shared/booking_status_notifier.dart';
import 'comment_modal.dart';

class MyTripCard extends StatefulWidget {
  final String title;
  final DateTime date;
  final String type;
  final String organizer;
  final String price;
  final String imageUrl;
  String status;
  final String reservationId;
  final String voyageId;
  final bool paymentState;
  final void Function() onRemoved;

  MyTripCard({
    super.key,
    required this.title,
    required this.date,
    required this.type,
    required this.organizer,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.reservationId,
    required this.voyageId,
    required this.paymentState,
    required this.onRemoved,
  });

  @override
  State<MyTripCard> createState() => _MyTripCardState();
}

class _MyTripCardState extends State<MyTripCard> {
  final supabase = Supabase.instance.client;

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

  Future<void> _cancelReservation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancel Reservation'),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            content: Text('Are you sure you want to cancel this reservation?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No', style: TextStyle(color: kPrimaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes', style: TextStyle(color: kPrimaryColor)),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await supabase
          .from('Reservation')
          .delete()
          .eq('id', widget.reservationId);

      await supabase.rpc(
        'increment_free_places',
        params: {'voyage_id_input': widget.voyageId},
      );

      BookingStatusNotifier.voyageBookingStatus.value[widget.voyageId] = false;
      BookingStatusNotifier.voyageBookingStatus.notifyListeners();

      widget.onRemoved();

      _showFlushbar('Reservation canceled.');
    } catch (e) {
      _showFlushbar('Error cancelling reservation: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.imageUrl,
              height: 190,
              width: 180,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 15),
                      SizedBox(width: 4),
                      Text(widget.type),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 15),
                      SizedBox(width: 4),
                      Text(
                        'Date: ${DateFormat('d MMM yyyy').format(widget.date)}',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.person_outlined, size: 18),
                      SizedBox(width: 4),
                      Text('Organizer: ${widget.organizer}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.attach_money_rounded, size: 18),
                      SizedBox(width: 4),
                      Text('Paid: ${widget.price} MAD'),
                    ],
                  ),
                  Row(children: [Text('Status: ${widget.status}')]),
                  SizedBox(height: 8),
                  if (widget.status == 'Upcoming')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _actionButton('Details', kPrimaryColor, () async {
                          final response =
                              await supabase
                                  .from('Voyage')
                                  .select('*, profiles(name)')
                                  .eq('id', widget.voyageId)
                                  .maybeSingle();

                          if (response == null) {
                            _showFlushbar('Error loading travel details.');
                            return;
                          }

                          final travel = Travel.fromMap(response);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TravelDetails(travel: travel),
                            ),
                          );
                        }),

                        SizedBox(width: 8),
                        _actionButton(
                          'Cancel',
                          Colors.redAccent,
                          _cancelReservation,
                        ),
                      ],
                    )
                  else if (widget.status == 'Completed')
                    _actionButton('Comment', Colors.green[400]!, () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CommentModal(voyageId: widget.voyageId),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: kDefaultPadding / 3,
          vertical: kDefaultPadding / 3,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
