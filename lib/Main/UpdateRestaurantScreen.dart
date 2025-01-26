import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/Components/theme.dart';
import 'package:seatview/model/restaurant.dart';
import 'package:seatview/model/user.dart';

class UpdateRestaurantScreen extends StatefulWidget {
  const UpdateRestaurantScreen({Key? key}) : super(key: key);

  @override
  _UpdateRestaurantScreenState createState() => _UpdateRestaurantScreenState();
}

class _UpdateRestaurantScreenState extends State<UpdateRestaurantScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _updatedData = {};
  bool _isUpdating = false;

  final List<File> _galleryImages = [];
  List<String> _existingGalleryImages = [];
  File? _profileImage;
  File? _layoutImage;

  final ImagePicker _picker = ImagePicker();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRestaurantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRestaurantData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

    if (userProvider.user?.restaurant != null) {
      await restaurantProvider.fetchRestaurant(
        userProvider.user!.restaurant!,
        userProvider.token ?? '',
      );

      if (restaurantProvider.restaurant != null) {
        setState(() {
          _existingGalleryImages = restaurantProvider.restaurant!.galleryImages ?? [];
        });
        print('Fetched existing gallery images: $_existingGalleryImages'); // Debug statement
      }
    }
  }

  Future<void> _updateRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isUpdating = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

    if (restaurantProvider.restaurant?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant ID not found!')),
      );
      return;
    }

    try {
      final url = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/restaurants/update/${restaurantProvider.restaurant!.id}',
      );

      final request = http.MultipartRequest('PUT', url)
        ..headers['token'] = userProvider.token ?? ''
        ..fields['name'] = _updatedData['name'] ?? ''
        ..fields['address'] = _updatedData['address'] ?? ''
        ..fields['phone'] = _updatedData['phone'] ?? ''
        ..fields['openingHours'] = _updatedData['openingHours'] ?? '';

      if (_profileImage != null) {
        await _addImageToRequest(request, _profileImage!, 'profileImage');
      }

      if (_layoutImage != null) {
        await _addImageToRequest(request, _layoutImage!, 'layoutImage');
      }

      for (final image in _galleryImages) {
        await _addImageToRequest(request, image, 'galleryImages');
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        await restaurantProvider.fetchRestaurant(
          userProvider.user!.restaurant!,
          userProvider.token ?? '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update restaurant')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating restaurant: $e')),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _addImageToRequest(
      http.MultipartRequest request,
      File image,
      String fieldName,
      ) async {
    final imageBytes = await image.readAsBytes();
    final mimeType = lookupMimeType(image.path);
    request.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        imageBytes,
        filename: image.path.split('/').last,
        contentType: MediaType.parse(mimeType!),
      ),
    );
  }

  Future<void> _pickImage({bool isProfile = false, bool isLayout = false}) async {
    if (isProfile || isLayout) {
      // For single image selection (profile or layout)
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          final file = File(pickedImage.path);
          if (isProfile) {
            _profileImage = file;
          } else if (isLayout) {
            _layoutImage = file;
          }
        });
      }
    } else {
      // For multiple image selection (gallery)
      final List<XFile> pickedImages = await _picker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        setState(() {
          _galleryImages.addAll(pickedImages.map((xFile) => File(xFile.path)));
        });
      }
    }
  }

  Widget _buildDetailsTab(Restaurant restaurant) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextFormField(
          initialValue: restaurant.name,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, // Use primary color
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
          ),
          onSaved: (value) => _updatedData['name'] = value,
          validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: restaurant.address,
          decoration: InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, // Use primary color
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
          ),
          onSaved: (value) => _updatedData['address'] = value,
          validator: (value) => value == null || value.isEmpty ? 'Address is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: restaurant.phone,
          decoration: InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, // Use primary color
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
          ),
          keyboardType: TextInputType.phone,
          onSaved: (value) => _updatedData['phone'] = value,
          validator: (value) => value == null || value.isEmpty ? 'Phone is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: restaurant.openingHours,
          decoration: InputDecoration(
            labelText: 'Opening Hours',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, // Use primary color
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, // Use error color
                width: 2.0,
              ),
            ),
          ),
          onSaved: (value) => _updatedData['openingHours'] = value,
        ),
      ],
    );
  }

  Widget _buildProfileAndLayoutTab(Restaurant restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _profileImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(_profileImage!, height: 150, width: 150, fit: BoxFit.cover),
          )
              : restaurant.profileImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(restaurant.profileImage!, height: 150, width: 150, fit: BoxFit.cover),
          )
              : Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[200],
            ),
            child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickImage(isProfile: true),
            icon: const Icon(Icons.image),
            label: const Text('Pick Profile Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _layoutImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(_layoutImage!, height: 150, width: 150, fit: BoxFit.cover),
          )
              : restaurant.layoutImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(restaurant.layoutImage!, height: 150, width: 150, fit: BoxFit.cover),
          )
              : Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[200],
            ),
            child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pickImage(isLayout: true),
            icon: const Icon(Icons.image),
            label: const Text('Pick Layout Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Column(
      children: [
        Expanded(
          child: _existingGalleryImages.isEmpty && _galleryImages.isEmpty
              ? const Center(
            child: Text(
              'No images selected',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _existingGalleryImages.length + _galleryImages.length,
            itemBuilder: (context, index) {
              if (index < _existingGalleryImages.length) {
                final url = _existingGalleryImages[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                );
              } else {
                final file = _galleryImages[index - _existingGalleryImages.length];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(file, fit: BoxFit.cover),
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Pick Images for Gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final restaurant = restaurantProvider.restaurant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Restaurant', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Profile & Layout'),
            Tab(text: 'Gallery'),
          ],
        ),
      ),
      body: restaurantProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurant == null
          ? const Center(child: Text('Failed to load restaurant data'))
          : Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(restaurant),
            _buildProfileAndLayoutTab(restaurant),
            _buildGalleryTab(),
          ],
        ),
      ),
      floatingActionButton: _isUpdating
          ? const CircularProgressIndicator()
          : FloatingActionButton(
        onPressed: _updateRestaurant,
        child: const Icon(Icons.save),
      ),
    );
  }
}