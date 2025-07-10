class Travel {
  final String id;
  final String title;
  final String type;
  final String description;
  final String imagePath;
  final DateTime date;
  final double price;
  String status;
  final int places;
  int freePlaces;
  final String organizerId;
  String organizerName = 'Unknown';

  Travel(
    this.id,
    this.title,
    this.type,
    this.description,
    this.imagePath,
    this.date,
    this.price,
    this.status,
    this.places,
    this.freePlaces,
    this.organizerId,
  );

  factory Travel.fromMap(Map<String, dynamic> map) {

    return Travel(
      map['id'],
      map['title'] ?? '',
      map['type'] ?? '',
      map['description'] ?? '',
      map['image_url'] ?? '',
      DateTime.parse(map['date']),
      (map['price_per_person'] as num).toDouble(),
      map['status'] ?? '',
      map['nbr_places'] ?? 0,
      map['free_places'] ?? 0,
      map['organizer_id'],
    )..organizerName = map['profiles']?['name'] ?? 'Unknown';
  }
}
