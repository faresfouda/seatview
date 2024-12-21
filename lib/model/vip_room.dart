class VipRoom {
  final String name;
  final String imageUrl;
  final String description;

  VipRoom({
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  factory VipRoom.fromJson(Map<String, dynamic> json) {
    return VipRoom(
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }
}
