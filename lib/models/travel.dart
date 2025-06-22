class Travel {
  final String title;
  final String type;
  final String description;
  final String imagePath;
  final DateTime date;
  final double price;
  final String status;
  final int places;

  Travel(
    this.title,
    this.type,
    this.description,
    this.imagePath,
    this.date,
    this.price,
    this.status,
    this.places
  );

  factory Travel.fromMap(Map<String, dynamic> map) {
    return Travel(
      map['title'],
      map['type'],
      map['description'],
      map['image_url'],
      DateTime.parse(map['date']),
      (map['price_per_person'] as num).toDouble(),
      map['status'],
      map['nbr_places']
    );
  }
}
