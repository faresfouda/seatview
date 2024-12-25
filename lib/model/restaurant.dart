

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
  final List<String> galleryImages;  // Keep this as a List<String>

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
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      openingHours: json['openingHours'],
      profileImage: json['profileImage']['secure_url'],
      layoutImage: json['layoutImage']['secure_url'],
      avgRating: json['avgRating'].toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      galleryImages: List<String>.from(json['galleryImages']?.map((image) => image['secure_url']) ?? []),  // Handle as list of strings
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
      'galleryImages': galleryImages,  // Directly map the list of strings
      'categories': categories,
    };
  }

}
