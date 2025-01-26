import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seatview/model/user.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class EditTableScreen extends StatefulWidget {
  final Map<String, dynamic> table;
  final Function onUpdate;  // Callback to refresh data after update

  EditTableScreen({required this.table, required this.onUpdate});

  @override
  _EditTableScreenState createState() => _EditTableScreenState();
}

class _EditTableScreenState extends State<EditTableScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tableNumberController = TextEditingController();
  TextEditingController _capacityController = TextEditingController(); // Controller for capacity input
  bool _isLoading = false;
  File? _imageFile;  // For holding the image file

  @override
  void initState() {
    super.initState();
    _tableNumberController.text = widget.table['tableNumber'].toString();
    _capacityController.text = widget.table['capacity'].toString(); // Initialize with current capacity
  }

  // Function to handle file selection (e.g., image picker)
  void _pickImage() async {
    // Use image picker or any other method to get a file
    // Example using ImagePicker (ensure you have the dependency)
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateTable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://restaurant-reservation-sys.vercel.app/tables/update/${widget.table['_id']}'),
      );

      request.headers['token'] = token!;

      // Add the table data to the request
      request.fields['tableNumber'] = _tableNumberController.text;
      request.fields['capacity'] = _capacityController.text;  // Add capacity to the form

      // Add the image if available
      if (_imageFile != null) {
        var mimeType = lookupMimeType(_imageFile!.path)?.split('/') ?? [];
        var imageStream = http.ByteStream(_imageFile!.openRead());
        var length = await _imageFile!.length();
        var multipartFile = http.MultipartFile(
          'image',
          imageStream,
          length,
          filename: _imageFile!.path.split('/').last,
          contentType: MediaType(mimeType[0], mimeType[1]),
        );
        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Table updated successfully')),
        );
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update table')),
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
        title: Text('Edit Table'),
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
                  controller: _tableNumberController,
                  decoration: InputDecoration(labelText: 'Table Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a table number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a capacity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _pickImage, // To pick an image
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 24),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _updateTable,
                  child: Text('Update Table'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
