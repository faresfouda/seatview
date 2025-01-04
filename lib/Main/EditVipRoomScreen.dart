import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seatview/model/vip_room.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:seatview/model/user.dart';

class EditVipRoomScreen extends StatefulWidget {
  final Map<String, dynamic> vipRoom;
  final Function onUpdate;  // Add the callback

  EditVipRoomScreen({required this.vipRoom, required this.onUpdate});

  @override
  _EditVipRoomScreenState createState() => _EditVipRoomScreenState();
}

class _EditVipRoomScreenState extends State<EditVipRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  List<File> _images = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.vipRoom['name']; // Initialize name controller with existing name
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _updateVipRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Get the token from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    // Create the multipart request for image upload
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('https://restaurant-reservation-sys.vercel.app/vip-rooms/update/${widget.vipRoom['_id']}'),
    );

    // Add the token to the headers
    request.headers['token'] = '$token';

    // Add the name to the request
    request.fields['name'] = _nameController.text;

    // Add the images to the request
    for (var image in _images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path,
        contentType: MediaType('image', 'jpeg'),));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('VIP Room updated successfully')),
        );
        widget.onUpdate();  // Trigger the callback to refresh VIP rooms
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update VIP Room')),
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
        title: Text('Edit VIP Room'),
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
                  decoration: InputDecoration(labelText: 'Room Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Room Images'),
                SizedBox(height: 8),
                _images.isEmpty
                    ? Center(child: Text('No images selected'))
                    : Wrap(
                  spacing: 8,
                  children: _images.map((image) {
                    return Stack(
                      children: [
                        Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _images.remove(image);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Images'),
                ),
                SizedBox(height: 24),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _updateVipRoom,
                  child: Text('Update VIP Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
