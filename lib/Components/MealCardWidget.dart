import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:seatview/Components/theme.dart';

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
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                mealImage,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Text(
                  mealName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Price Text with proper spacing
                  Expanded(
                    child: Text(
                      'Price: ${mealPrice.toStringAsFixed(2)} L.E',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],  // Gray color for the price
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Add Button Icon with a cleaner, more meaningful icon
                  IconButton(
                    onPressed: () => onAddToOrder(),
                    icon: Icon(
                      Icons.add_circle_outlined,  // A more specific "add to cart" icon
                      color: Theme.of(context).primaryColor,  // Primary color for the icon
                      size: 24,  // Adjusted icon size for better visibility
                    ),
                    splashRadius: 24,  // Optional: adjust the splash radius
                  ),
                ],
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
  final int quantity; // Add quantity parameter
  final Function onRemove;

  const CheckoutMealCardWidget({
    required this.mealName,
    required this.mealImage,
    required this.mealPrice,
    required this.quantity, // Receive quantity as a parameter
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadius, // Apply border radius from theme
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: ${(mealPrice * quantity).toStringAsFixed(2)} L.E', // Total price based on quantity
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor, // Use primaryColor from theme
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Quantity: $quantity', // Display quantity
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600], // Gray color for the quantity
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              onPressed: () => onRemove(),
              icon: Icon(Icons.remove_circle, color: AppTheme.secondaryColor), // Use secondaryColor from theme
            ),
          ],
        ),
      ),
    );
  }
}

