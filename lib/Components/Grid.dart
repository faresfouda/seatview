// import 'package:flutter/material.dart';
// import 'package:seatview/Components/MealCardWidget.dart';
//
//
// class MealGridView extends StatelessWidget {
//   final List<MealsRecord> meals;
//
//   const MealGridView({
//     Key? key,
//     required this.meals,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GridView.builder(
//         physics: NeverScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: 0.79,
//         ),
//         itemCount: meals.length, // The number of items in the grid
//         itemBuilder: (context, index) {
//           // Return MealCardWidget for each meal item
//           return MealCardWidget(
//             mealName: meals[index].mealName, // Pass meal name
//             mealImage: meals[index].mealImage,
//             mealFavorites: meals[index].mealFavorites, // Pass meal image
//           );
//         },
//       ),
//     );
//   }
// }
