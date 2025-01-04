import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/API/restaurants_service.dart';
import 'package:seatview/model/user.dart';

class AddVipRoomScreen extends StatefulWidget {
  final Function onUpdate;  // Callback to refresh data after add

  AddVipRoomScreen({required this.onUpdate});

  @override
  _AddVipRoomScreenState createState() => _AddVipRoomScreenState();
}

class _AddVipRoomScreenState extends State<AddVipRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final OwnerService _ownerService = OwnerService();

  bool _isLoading = false;

  Future<void> _pickImages() async {
    print('Starting image picker');
    final pickedImages = await _ownerService.pickGalleryImages();
    if (pickedImages.isNotEmpty) {
      print('Selected images: ${pickedImages.map((image) => image.path).toList()}');
      setState(() {
        _images = pickedImages;
      });
    } else {
      print('No images selected');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final restaurantId = userProvider.user?.restaurant;

      if (token == null || restaurantId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User authentication failed')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _ownerService.submitVipRoomData(
        token: token,
        name: _nameController.text.trim(),
        capacity: _capacityController.text.trim(),
        restaurantId: restaurantId,
        images: _images,
        onSuccess: () {
          // Trigger the callback to refresh the VIP room list
          widget.onUpdate();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('VIP Room added successfully!')),
          );
          Navigator.pop(context);  // This will pop the screen after success
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building AddVipRoomScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Add VIP Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      print('Name field is empty');
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      print('Capacity field is empty');
                      return 'Please enter capacity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _pickImages,
                  child: Text('Upload Images'),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _images
                      .map((image) => Image.file(
                    File(image.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text('Add VIP Room'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
