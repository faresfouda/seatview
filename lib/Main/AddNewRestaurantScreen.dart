import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/Main/MainScreen.dart';
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

  bool _isSubmitting = false;
  File? _profileImage;
  File? _layoutImage;
  List<File> _galleryImages = [];
  final List<String> _categories = ['drinks', 'desserts', 'meals'];
  List<String> _selectedCategories = [];

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

  // Debugging function to print all form values
  void _printFormData() {
    print("Restaurant Name: ${_nameController.text.trim()}");
    print("Address: ${_addressController.text.trim()}");
    print("Phone: ${_phoneController.text.trim()}");
    print("Opening Hours: ${_openingHoursController.text.trim()}");
    print("Selected Categories: $_selectedCategories");
    print("Profile Image: ${_profileImage != null ? _profileImage!.path : 'None'}");
    print("Layout Image: ${_layoutImage != null ? _layoutImage!.path : 'None'}");
    print("Gallery Images: ${_galleryImages.map((image) => image.path).join(', ')}");
  }

  // Submit restaurant data
  Future<void> _submitRestaurantData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? token = userProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User is not authenticated"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select at least one category."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Step 1: Submit restaurant details
      await _ownerService.submitRestaurantDetails(
        token: token,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        openingHours: _openingHoursController.text.trim(),
        categories: _selectedCategories,
        onSuccess: (restaurantId) async {
          // Step 2: Submit images
          await _ownerService.submitRestaurantImages(
            token: token,
            restaurantId: restaurantId,
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
              setState(() {
                _profileImage = null;
                _layoutImage = null;
                _galleryImages.clear();
                _selectedCategories.clear();
              });

              // Navigate to the MainScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(userRole: 'restaurantOwner',)),
              );
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ));
            },
          );
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
              // Categories selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categories.map((category) {
                  return CheckboxListTile(
                    title: Text(category),
                    value: _selectedCategories.contains(category),
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                      // Debugging: Print the updated selected categories
                      print("Updated selected categories: $_selectedCategories");
                    },
                  );
                }).toList(),
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
              ElevatedButton(
                onPressed: ()async{
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  await userProvider.logout();
                  await userProvider.checkUserSession();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text("Submit"),
              ),
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
