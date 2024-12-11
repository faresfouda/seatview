import 'package:flutter/material.dart';


import 'package:flutter/material.dart';

class MealCardWidget extends StatelessWidget {
  final String mealName;
  final String mealImage;
  final bool mealFavorites;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToOrder;
  final double mealPrice;

  const MealCardWidget({
    Key? key,
    required this.mealName,
    required this.mealImage,
    required this.mealFavorites,
    required this.onFavoriteToggle,
    required this.onAddToOrder,
    required this.mealPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5, // Add shadow for a card-like appearance
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mealImage,
                fit: BoxFit.cover,
                height: 120, // Set a fixed height for the image
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${mealName}',  // Display the meal name or price
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,  // Limit the text to one line
              overflow: TextOverflow.ellipsis,  // Truncate text with ellipsis if it overflows
            ),

            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${mealPrice.toStringAsFixed(2)} L.E',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onFavoriteToggle,
                      icon: Icon(
                        mealFavorites ? Icons.favorite : Icons.favorite_border,
                        color: mealFavorites ? Colors.red : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: onAddToOrder,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




class MealsRecord {
  final String mealName;
  final String mealImage;
  final bool mealFavorites;

  MealsRecord({
    required this.mealName,
    required this.mealImage,
    required this.mealFavorites,
  });
}
