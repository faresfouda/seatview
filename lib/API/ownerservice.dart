import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';


class OwnerService {
  final ImagePicker _picker = ImagePicker();

  // Pick profile image
  Future<File?> pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Pick layout image
  Future<File?> pickLayoutImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Pick multiple gallery images
  Future<List<File>> pickGalleryImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      return pickedFiles.map((file) => File(file.path)).toList();
    }
    return [];
  }

  // Submit restaurant data
  Future<void> submitRestaurantData({
    required String token,
    required String name,
    required String address,
    required String phone,
    required String openingHours,
    required List<String> categories,
    File? profileImage,
    File? layoutImage,
    List<File>? galleryImages,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    galleryImages = galleryImages ?? [];
    // API URL
    const String url = "https://restaurant-reservation-sys.vercel.app/restaurants/create";

    // Prepare the request body
    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['token'] = token
      ..fields['name'] = name
      ..fields['address'] = address
      ..fields['phone'] = phone
      ..fields['openingHours'] = openingHours;

    // Add categories to request
    for (int i = 0; i < categories.length; i++) {
      request.fields['categories[$i]'] = categories[i].trim();
    }

    // Add images if selected
    if (profileImage != null) {
      var profileImageFile = await http.MultipartFile.fromPath(
        'profileImage', profileImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(profileImageFile);
    }

    if (layoutImage != null) {
      var layoutImageFile = await http.MultipartFile.fromPath(
        'layoutImage', layoutImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(layoutImageFile);
    }

    for (var image in galleryImages) {
      var galleryImageFile = await http.MultipartFile.fromPath(
        'gallery_images[]', image.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(galleryImageFile);
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        onSuccess();
        print(responseBody);
      } else {
        final error = json.decode(responseBody);
        onError("Failed to add restaurant: ${error['message']}");
      }
    } catch (e) {
      onError("Error: $e");
    }
  }
}
