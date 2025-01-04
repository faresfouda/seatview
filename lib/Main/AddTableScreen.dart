import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/ownerservice.dart';
import 'package:seatview/model/user.dart';

class AddTableScreen extends StatefulWidget {
  final Function onUpdate;  // Callback to refresh data after add

  AddTableScreen({required this.onUpdate});

  @override
  _AddTableScreenState createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  bool _isLoading = false;
  final OwnerService _ownerService = OwnerService();  // Add this line to instantiate _ownerService

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

      // Parse tableNumber and capacity to int
      final int tableNumber = int.tryParse(_tableNumberController.text.trim()) ?? 0;
      final int capacity = int.tryParse(_capacityController.text.trim()) ?? 0;

      if (tableNumber == 0 || capacity == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter valid numbers for table number and capacity')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _ownerService.submitTableData(
        token: token,
        restaurantId: restaurantId,
        tableNumber: tableNumber.toString(), // Send as string to API
        capacity: capacity.toString(), // Send as string to API
        onSuccess: () {
          // Trigger the callback to refresh the table list
          widget.onUpdate();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Table added successfully!')),
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
    print('Building AddTableScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Table'),
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
                TextFormField(
                  controller: _capacityController,
                  decoration: InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the capacity';
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
                        : Text('Add Table'),
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
