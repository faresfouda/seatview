import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  // Import image picker
import 'package:provider/provider.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/model/user.dart';

class UpdateRestaurantScreen extends StatefulWidget {
  const UpdateRestaurantScreen();

  @override
  _UpdateRestaurantScreenState createState() => _UpdateRestaurantScreenState();
}

class _UpdateRestaurantScreenState extends State<UpdateRestaurantScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> updatedData = {};
  bool _isUpdating = false;
  List<File>? _galleryImages = [];
  File? _profileImage;
  File? _layoutImage;

  final ImagePicker _picker = ImagePicker();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

    if (userProvider.user?.restaurant != null) {
      restaurantProvider.fetchRestaurant(
        userProvider.user!.restaurant ?? '',
        userProvider.token ?? '',
      );
    }
  }

  Future<void> updateRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _isUpdating = true;
    });

    try {
      if (restaurantProvider.restaurant?.id != null) {
        final profileImage = _profileImage ?? (restaurantProvider.restaurant?.profileImage != null ? File(restaurantProvider.restaurant!.profileImage!) : null);
        final layoutImage = _layoutImage ?? (restaurantProvider.restaurant?.layoutImage != null ? File(restaurantProvider.restaurant!.layoutImage!) : null);

        await restaurantProvider.updateRestaurant(
          restaurantId: restaurantProvider.restaurant!.id!,
          token: userProvider.token ?? '',
          name: updatedData['name'] ?? '',
          address: updatedData['address'] ?? '',
          phone: updatedData['phone'] ?? '',
          openingHours: updatedData['openingHours'] ?? '',
          profileImage: profileImage,
          layoutImage: layoutImage,
          galleryImages: _galleryImages ?? [],
        );
        setState(() {
          if (userProvider.user?.restaurant != null) {
            restaurantProvider.fetchRestaurant(
              userProvider.user!.restaurant ?? '',
              userProvider.token ?? '',
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant ID not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating restaurant: $e')),
      );
      print(e);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _pickImage({bool isProfile = false, bool isLayout = false}) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        final file = File(pickedImage.path);
        if (isProfile) {
          _profileImage = file;
          updatedData['profileImage'] = _profileImage?.path;
        } else if (isLayout) {
          _layoutImage = file;
          updatedData['layoutImage'] = _layoutImage?.path;
        } else {
          _galleryImages?.add(file);
          updatedData['galleryImages'] = _galleryImages?.map((e) => e.path).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final restaurant = restaurantProvider.restaurant;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Restaurant'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Strings'),
            Tab(text: 'Profile & Layout'),
            Tab(text: 'Gallery'),
          ],
        ),
      ),
      body: restaurantProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : restaurant == null
          ? Center(child: Text('Failed to load restaurant data'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Strings Tab
              ListView(
                children: [
                  TextFormField(
                    initialValue: restaurant.name,
                    decoration: InputDecoration(labelText: 'Name'),
                    onSaved: (value) => updatedData['name'] = value,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
                  ),
                  TextFormField(
                    initialValue: restaurant.address,
                    decoration: InputDecoration(labelText: 'Address'),
                    onSaved: (value) => updatedData['address'] = value,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Address is required' : null,
                  ),
                  TextFormField(
                    initialValue: restaurant.phone,
                    decoration: InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => updatedData['phone'] = value,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Phone is required' : null,
                  ),
                  TextFormField(
                    initialValue: restaurant.openingHours,
                    decoration: InputDecoration(labelText: 'Opening Hours'),
                    onSaved: (value) => updatedData['openingHours'] = value,
                  ),
                ],
              ),
              // Profile & Layout Tab
              Column(
                children: [
                  _profileImage != null
                      ? Image.file(File(_profileImage!.path), height: 150, width: 150, fit: BoxFit.cover)
                      : restaurant.profileImage != null
                      ? Image.network(restaurant.profileImage!, height: 150, width: 150, fit: BoxFit.cover)
                      : Container(),
                  ElevatedButton(
                    onPressed: () => _pickImage(isProfile: true),
                    child: Text('Pick Profile Image'),
                  ),
                  SizedBox(height: 20),
                  _layoutImage != null
                      ? Image.file(File(_layoutImage!.path), height: 150, width: 150, fit: BoxFit.cover)
                      : restaurant.layoutImage != null
                      ? Image.network(restaurant.layoutImage!, height: 150, width: 150, fit: BoxFit.cover)
                      : Container(),
                  ElevatedButton(
                    onPressed: () => _pickImage(isLayout: true),
                    child: Text('Pick Layout Image'),
                  ),
                ],
              ),
              // Gallery Tab
              Column(
                children: [
                  _galleryImages != null && _galleryImages!.isNotEmpty
                      ? Column(
                    children: _galleryImages!.map((file) {
                      return Image.file(File(file.path), height: 100, width: 100, fit: BoxFit.cover);
                    }).toList(),
                  )
                      : Container(),
                  ElevatedButton(
                    onPressed: () => _pickImage(),
                    child: Text('Pick Images for Gallery'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isUpdating
          ? CircularProgressIndicator()
          : FloatingActionButton(
        onPressed: updateRestaurant,
        child: Icon(Icons.save),
      ),
    );
  }
}
