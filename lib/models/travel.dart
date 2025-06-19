class Travel {
  final String name;
  final String location;
  final String imagePath;
  final double price;

  Travel(this.name, this.location, this.imagePath, this.price);

  factory Travel.fromMap(Map<String, dynamic> map) {
    return Travel(
      map['title'],
      map['type'],
      map['image_url'],
      (map['price_per_person'] as num).toDouble(),
    );
  }
}
