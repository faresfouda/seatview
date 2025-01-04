

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String openingHours;
  final String profileImage;
  final String layoutImage;
  final double avgRating;
  final List<String> categories;
  final List<String> galleryImages;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.profileImage,
    required this.layoutImage,
    required this.avgRating,
    required this.categories,
    required this.galleryImages,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? 'Unknown ID',
      name: json['name'] ?? 'Unknown Name',
      address: json['address'] ?? 'Unknown Address',
      phone: json['phone'] ?? 'Unknown Phone',
      openingHours: json['openingHours'] ?? 'Unknown Hours',
      profileImage: json['profileImage']?['secure_url'] ?? '', // Handle potential null
      layoutImage: json['layoutImage']?['secure_url'] ?? '', // Handle potential null
      avgRating: (json['avgRating']?.toDouble()) ?? 0.0, // Default to 0.0 if null
      categories: List<String>.from(json['categories'] ?? []), // Default to empty list
      galleryImages: List<String>.from(json['galleryImages']?.map((image) => image['secure_url']) ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'openingHours': openingHours,
      'profileImage': profileImage,
      'layoutImage': layoutImage,
      'avgRating': avgRating,
      'categories': categories,
      'galleryImages': galleryImages,
    };
  }
}

