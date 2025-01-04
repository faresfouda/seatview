import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/model/user.dart';

class AddNewRestaurantScreen extends StatefulWidget {
  @override
  _AddNewRestaurantScreenState createState() => _AddNewRestaurantScreenState();
}

class _AddNewRestaurantScreenState extends State<AddNewRestaurantScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _openingHoursController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();

  bool _isSubmitting = false;
  File? _profileImage;
  File? _layoutImage;
  List<File> _galleryImages = [];

  final OwnerService _ownerService = OwnerService();

  // Pick profile image
  Future<void> _pickProfileImage() async {
    final pickedImage = await _ownerService.pickProfileImage();
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  // Pick layout image
  Future<void> _pickLayoutImage() async {
    final pickedImage = await _ownerService.pickLayoutImage();
    if (pickedImage != null) {
      setState(() {
        _layoutImage = pickedImage;
      });
    }
  }

  // Pick gallery images
  Future<void> _pickGalleryImages() async {
    final pickedImages = await _ownerService.pickGalleryImages();
    setState(() {
      _galleryImages = pickedImages;
    });
  }

  // Submit restaurant data
  Future<void> _submitRestaurantData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? token = userProvider.token;

    if (token == null) {
      // Handle error if token is not available
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User is not authenticated"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _ownerService.submitRestaurantData(
        token: token,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        openingHours: _openingHoursController.text.trim(),
        categories: _categoriesController.text.trim().split(','),
        profileImage: _profileImage,
        layoutImage: _layoutImage,
        galleryImages: _galleryImages,
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Restaurant added successfully!"),
            backgroundColor: Colors.green,
          ));

          // Clear input fields after successful submission
          _nameController.clear();
          _addressController.clear();
          _phoneController.clear();
          _openingHoursController.clear();
          _categoriesController.clear();
          setState(() {
            _profileImage = null;
            _layoutImage = null;
            _galleryImages.clear();
          });
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ));
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Restaurant"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Restaurant Name"),
              ),
              // Address
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address"),
              ),
              // Phone number
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              // Opening hours
              TextField(
                controller: _openingHoursController,
                decoration: InputDecoration(labelText: "Opening Hours"),
              ),
              // Categories
              TextField(
                controller: _categoriesController,
                decoration: InputDecoration(
                  labelText: "Categories (comma-separated, e.g., desserts,drinks)",
                ),
              ),
              SizedBox(height: 20),

              // Image selection buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickProfileImage,
                      child: Text("Pick Profile Image"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickLayoutImage,
                      child: Text("Pick Layout Image"),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickGalleryImages,
                      child: Text("Pick Gallery Images"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Display selected images
              if (_profileImage != null) Text("Profile image selected"),
              if (_layoutImage != null) Text("Layout image selected"),
              if (_galleryImages.isNotEmpty) Text("Gallery images selected"),

              SizedBox(height: 20),

              // Submit button
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRestaurantData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
