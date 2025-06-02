import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Travel {
  final String name;
  final String location;
  final String imagePath;
  final double rating;

  Travel(this.name, this.location, this.imagePath, this.rating);
}

class TravelsMenu extends StatelessWidget {
  TravelsMenu({super.key});

  final List<Travel> travels = [
    Travel("Jemaa el-Fnaa", "Marrakesh", "assets/images/logo.svg", 4.5),
    Travel("Marina", "Agadir", "assets/images/logo.svg", 4.5),
    Travel("Hassan II Mosque", "Casablanca", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
    Travel("Ait Benhaddou", "Ouarzazate", "assets/images/logo.svg", 4.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: travels.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          return TravelCard(travel: travels[index]);
        },
      ),
    );
  }
}

class TravelCard extends StatelessWidget {
  final Travel travel;

  const TravelCard({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withAlpha(20),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SvgPicture.asset(
              travel.imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              travel.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  travel.location,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  travel.rating.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
