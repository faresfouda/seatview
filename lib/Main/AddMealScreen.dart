import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/model/user.dart';

class AddMealScreen extends StatefulWidget {
  final Function onUpdate;  // Callback to refresh data after add

  AddMealScreen({required this.onUpdate});

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;  // Single image
  final ImagePicker _picker = ImagePicker();
  final OwnerService _ownerService = OwnerService();
  String _category = 'meal'; // Default category
  bool _isLoading = false;

  // Pick a single image
  Future<void> _pickImage() async {
    print('Starting image picker');
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('Selected image: ${pickedFile.path}');
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected');
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

      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _ownerService.submitMealData(
        token: token,
        name: _nameController.text.trim(),
        desc: _descController.text.trim(),
        price: _priceController.text.trim(),
        restaurantId: restaurantId,
        image: _image!,  // Pass the single image
        category: _category,
        onSuccess: () {
          // Trigger the callback to refresh the meal list
          widget.onUpdate();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Meal added successfully!')),
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
    print('Building AddMealScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Meal'),
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
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Upload Image'),
                ),
                if (_image != null)
                  Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(labelText: 'Category'),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                  items: ['desserts', 'meal', 'drinks']
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
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
                        : Text('Add Meal'),
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
