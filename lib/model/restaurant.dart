class Restaurant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String openingHours;
  final String profileImage;
  final String layoutImage;
  final List<ImageData> galleryImages;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.profileImage,
    required this.layoutImage,
    required this.galleryImages,
  });

  // Factory method to create a Restaurant from a JSON object
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Mapping gallery images to ImageData
    var galleryList = json['galleryImages'] as List;
    List<ImageData> galleryUrls = galleryList.map((item) => ImageData.fromJson(item)).toList();

    return Restaurant(
      id: json['_id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      openingHours: json['openingHours'],
      profileImage: json['profileImage']['secure_url'],
      layoutImage: json['layoutImage']['secure_url'],
      galleryImages: galleryUrls,
    );
  }
}
class ImageData {
  final String secureUrl;
  final String publicId;

  ImageData({
    required this.secureUrl,
    required this.publicId,
  });

  // Factory method to create ImageData from JSON
  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      secureUrl: json['secure_url'],
      publicId: json['public_id'],
    );
  }
}
