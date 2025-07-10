import 'dart:io';

class Trip {
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final String price;
  final String seats;
  final String status;
  final File? image;
  final String? programUrl;
  final String organizerId;  // Add this field

  Trip({
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.price,
    required this.seats,
    required this.status,
    this.image,
    this.programUrl,
    required this.organizerId,
  });
}
