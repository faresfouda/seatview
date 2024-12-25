// @override
// Widget build(BuildContext context) {
//   final favoritesProvider = Provider.of<FavoritesProvider>(context);
//   final restaurantProvider = Provider.of<RestaurantProvider>(context);
//
//   final restaurants = restaurantProvider.restaurants;
//
//   return Scaffold(
//     body: SafeArea(
//       child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Restaurants',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, 'RestaurantsScreen');
//                     },
//                     child: const Text('View More',
//                         style: TextStyle(color: Colors.red)),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 height: 250,
//                 child: restaurants.isEmpty
//                     ? Center(child: CircularProgressIndicator())
//                     : ListView.builder(
//                   controller: _scrollController,
//                   scrollDirection: Axis.horizontal,
//                   physics: const BouncingScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: restaurants.length,
//                   itemBuilder: (context, index) {
//                     final restaurant = restaurants[index];
//                     final isFavorite =
//                     favoritesProvider.isFavorite(restaurant);
//
//                     return Container(
//                       width: 380,
//                       margin: const EdgeInsets.only(right: 10),
//                       child: SingleChildScrollView(
//                         child: RestaurantCard(
//                           imageUrl: restaurant.profileImage,
//                           title: restaurant.name,
//                           description: restaurant.address,
//                           rating: restaurant.avgRating ?? 0,
//                           reviewsCount: 10, // Placeholder
//                           onFavoritePressed: () {
//                             favoritesProvider.toggleFavorite(restaurant);
//                           },
//                           restaurant: restaurant,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
