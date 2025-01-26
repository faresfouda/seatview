import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/Components/theme.dart';
import 'package:seatview/Main/MainScreen.dart';
import 'package:seatview/model/user.dart';

class AddNewRestaurantScreen extends StatefulWidget {
  @override
  _AddNewRestaurantScreenState createState() => _AddNewRestaurantScreenState();
}

class _AddNewRestaurantScreenState extends State<AddNewRestaurantScreen>
    with SingleTickerProviderStateMixin {
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _pickProfileImage() async {
    final pickedImage = await _ownerService.pickProfileImage();
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  Future<void> _pickLayoutImage() async {
    final pickedImage = await _ownerService.pickLayoutImage();
    if (pickedImage != null) {
      setState(() {
        _layoutImage = pickedImage;
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final pickedImages = await _ownerService.pickGalleryImages();
    setState(() {
      _galleryImages = pickedImages;
    });
  }

  Future<void> _submitRestaurantData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? token = userProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User is not authenticated"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one category."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _ownerService.submitRestaurantDetails(
        token: token,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        openingHours: _openingHoursController.text.trim(),
        categories: _selectedCategories,
        onSuccess: (restaurantId) async {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.updateUserRestaurant(restaurantId); // Update user's restaurant state

          await _ownerService.submitRestaurantImages(
            token: token,
            restaurantId: restaurantId,
            profileImage: _profileImage,
            layoutImage: _layoutImage,
            galleryImages: _galleryImages,
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Restaurant added successfully!"),
                  backgroundColor: Colors.green,
                ),
              );

              // Clear all inputs
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

              // Navigate to MainScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(
                    userRole: 'restaurantOwner',
                  ),
                ),
              );
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text("Add Restaurant"),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info, color: Colors.black), text: "Details"),
            Tab(icon: Icon(Icons.restaurant_outlined, color: Colors.black), text: "Categories"),
            Tab(icon: Icon(Icons.image, color: Colors.black), text: "Images"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Restaurant Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a restaurant name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _openingHoursController,
                  decoration: const InputDecoration(
                    labelText: "Opening Hours",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter opening hours';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          // Categories Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
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
                  },
                );
              }).toList(),
            ),
          ),
          // Images Tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _pickProfileImage,
                  child: const Text("Pick Profile Image"),
                ),
                if (_profileImage != null)
                  Image.file(
                    _profileImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickLayoutImage,
                  child: const Text("Pick Layout Image"),
                ),
                if (_layoutImage != null)
                  Image.file(
                    _layoutImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickGalleryImages,
                  child: const Text("Pick Gallery Images"),
                ),
                if (_galleryImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _galleryImages.map((image) {
                      return Image.file(
                        image,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSubmitting ? null : _submitRestaurantData,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}