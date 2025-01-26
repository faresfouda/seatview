import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:seatview/model/user.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class EditMealScreen extends StatefulWidget {
  final Map<String, dynamic> meal;
  final Function onUpdate;  // Callback to refresh data after update

  EditMealScreen({required this.meal, required this.onUpdate});

  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.meal['name'];
    _descController.text = widget.meal['desc'];
    _priceController.text = widget.meal['price'].toString();
    _categoryController.text = widget.meal['category'];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Get the token from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://restaurant-reservation-sys.vercel.app/meals/update/${widget.meal['_id']}'),
      );

      request.headers['token'] = token!;

      // Add meal data as form fields
      request.fields['name'] = _nameController.text;
      request.fields['desc'] = _descController.text;
      request.fields['price'] = _priceController.text;
      request.fields['category'] = _categoryController.text;

      // Add image if picked
      if (_image != null) {
        var imageBytes = await _image!.readAsBytes();
        var imageMimeType = lookupMimeType(_image!.path);

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: _image!.path.split('/').last,
            contentType: MediaType.parse(imageMimeType!),
          ),
        );
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal updated successfully')),
        );
        widget.onUpdate();  // Trigger the callback to refresh meal data
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update meal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meal'),
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
                  decoration: InputDecoration(labelText: 'Meal Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a meal name';
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
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _image == null
                    ? ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                )
                    : Image.file(_image!),
                SizedBox(height: 24),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _updateMeal,
                  child: Text('Update Meal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
