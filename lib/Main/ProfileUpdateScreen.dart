import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Import Provider for accessing UserProvider
import 'package:seatview/model/user.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String? token;
  final Function(String, String) onUpdate;

  ProfileUpdateScreen({
    required this.name,
    required this.phoneNumber,
    required this.token,
    required this.onUpdate,
  });

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  XFile? _imageFile; // Holds the picked image

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      print('Picked image: ${_imageFile!.path}');
    }
  }

  Future<void> _updateProfile() async {
    if (widget.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated.')),
      );
      return;
    }

    final url = 'https://restaurant-reservation-sys.vercel.app/users/update';
    final headers = {
      'token': widget.token!,
    };

    final name = _nameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    if (name.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone number are required.')),
      );
      return;
    }

    var request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields['name'] = name
      ..fields['phone'] = phoneNumber;

    // Add the image to the request if it's selected
    if (_imageFile != null) {
      var imageFile = await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType: MediaType('image', 'jpeg') // Adjust the content type based on your image type
      );
      request.files.add(imageFile);
    }

    // Log the fields for debugging
    print('Sending request...');
    print('Headers: ${request.headers}');
    print('Fields: ${request.fields}');

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        if (responseData['status'] == 'success') {
          final updatedUser = UserModel.fromJson(responseData['user']);
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.updateUser(updatedUser); // Ensure this updates the UserProvider with the new image URL

          widget.onUpdate(name, phoneNumber);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${responseData['message']}')),
          );
        }
      }


    } catch (error) {
      print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profile Update',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Picker Section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : (widget.name != null && widget.token != null)
                      ? NetworkImage(
                    Provider.of<UserProvider>(context, listen: false)
                        .user
                        ?.image
                        ?.secureUrl ??
                        'https://i.pinimg.com/474x/6d/10/74/6d107462bcc8f71fe80bb1cf6b0d3ab7.jpg',
                  )
                      : const NetworkImage(
                    'https://i.pinimg.com/474x/6d/10/74/6d107462bcc8f71fe80bb1cf6b0d3ab7.jpg',
                  ),
                ),

              ),
            ),
            const SizedBox(height: 20),

            // Name input field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Phone number input field
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Save changes button
            Center(
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
