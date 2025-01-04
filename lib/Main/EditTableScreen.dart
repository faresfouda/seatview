import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:seatview/model/user.dart';
import 'dart:convert';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tableNumberController.text = widget.table['tableNumber'].toString();  // Initialize with current table number
  }

  Future<void> _updateTable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Get the token from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;

    // Make the PUT request to update the table
    try {
      final response = await http.put(
        Uri.parse('https://restaurant-reservation-sys.vercel.app/tables/update/${widget.table['_id']}'),
        headers: {
          'token': '$token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tableNumber': _tableNumberController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Table updated successfully')),
        );
        widget.onUpdate();  // Trigger the callback to refresh table data
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
