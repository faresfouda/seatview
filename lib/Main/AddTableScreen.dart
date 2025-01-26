import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/model/user.dart';


class AddTableScreen extends StatefulWidget {
  final VoidCallback onUpdate;

  const AddTableScreen({Key? key, required this.onUpdate}) : super(key: key);

  @override
  _AddTableScreenState createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final OwnerService _ownerService = OwnerService(); // Adjust as needed

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token ?? '';
    final restaurantId = userProvider.user?.restaurant;

    await _ownerService.submitTableData(
      token: token,
      restaurantId: restaurantId??'',
      tableNumber: _tableNumberController.text.trim(),
      capacity: _capacityController.text.trim(),
      image: _selectedImage!,
      onSuccess: () {
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Table added successfully!')),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tableNumberController,
                decoration: const InputDecoration(
                  labelText: 'Table Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the table number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Column(
                  children: [
                    Image.file(
                      _selectedImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Table'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
}
