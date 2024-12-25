import 'package:flutter/material.dart';

class VIPRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;

  const VIPRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    // Get the first image from the room's images list
    final imageUrl = room['images'][0]['secure_url'] ?? ''; // Fallback to empty string if no image is found

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
              },
            )
                : Image.asset('assets/placeholder.png', fit: BoxFit.cover, height: 150),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['name'] ?? 'Unknown Room', // Fallback if name is missing
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(room['description'] ?? 'No description available'), // Fallback for description
              ],
            ),
          ),
        ],
      ),
    );
  }
}
