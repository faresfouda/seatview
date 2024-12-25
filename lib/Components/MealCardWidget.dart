import 'package:flutter/material.dart';

class MealCardWidget extends StatelessWidget {
  final String mealName;
  final String mealImage;
  final double mealPrice;
  final Function onTap;
  final Function onAddToOrder;

  const MealCardWidget({
    required this.mealName,
    required this.mealImage,
    required this.mealPrice,
    required this.onTap,
    required this.onAddToOrder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 8,  // Increased elevation for a prominent floating effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),  // Rounded corners
        ),
        shadowColor: Colors.black.withOpacity(0.2),  // Add a subtle shadow color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image with circular border for better style, with reduced height
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                mealImage,
                height: 120, // Reduced image height further to avoid overflow
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Text(
                mealName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,  // Slightly smaller font size
                  color: Colors.black87,
                ),
                maxLines: 1,  // Limit text to one line
                overflow: TextOverflow.ellipsis,  // Ellipsis when text overflows
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(
                'Price: ${mealPrice.toStringAsFixed(2)} L.E',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                  fontSize: 14,  // Slightly smaller font size for price
                ),
              ),
            ),

            // "Add to Order" button with a rectangular shape and a better icon
            Padding(
              padding: const EdgeInsets.all(8.0),  // Reduced padding to avoid overflow
              child: Align(
                alignment: Alignment.centerRight,  // Align the button to the right
                child: Container(
                  width: 120,  // Set width for the button
                  height: 40,  // Set height for the button
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),  // Rounded corners for the button
                  ),
                  child: TextButton.icon(
                    onPressed: () => onAddToOrder(),
                    icon: Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),  // Smaller icon size
                    label: Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),  // Rounded corners
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CheckoutMealCardWidget extends StatelessWidget {
  final String mealName;
  final String mealImage;
  final double mealPrice;
  final Function onRemove;

  const CheckoutMealCardWidget({
    required this.mealName,
    required this.mealImage,
    required this.mealPrice,
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Meal Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mealImage,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Meal Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: ${mealPrice.toStringAsFixed(2)} L.E',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              onPressed: () => onRemove(),
              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

