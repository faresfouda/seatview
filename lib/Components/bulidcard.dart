import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onPressed;

  // Constructor to initialize the parameters
  const CategoryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text('$count Items', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}
