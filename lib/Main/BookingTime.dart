import 'package:flutter/material.dart';
import 'package:seatview/API/DatabaseHelper_BookedTables.dart';
import 'package:seatview/Components/ElevatedButton.dart';
import 'package:seatview/Main/RestaurantMenuScreen.dart';
import 'package:seatview/Main/MainScreen.dart';

class BookingTime extends StatefulWidget {
  final int selectedTable;
  final bool isOrder;
  final Map<String, dynamic> restaurant;

  const BookingTime({
    required this.selectedTable,
    required this.isOrder,
    required this.restaurant,
    Key? key,
  }) : super(key: key);

  @override
  _BookingTimeState createState() => _BookingTimeState();
}

class _BookingTimeState extends State<BookingTime> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Book Your Table',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Selection Header
            Text(
              'You have selected Table ${widget.selectedTable + 1}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Date Selection
            _buildDateSelector(),
            const SizedBox(height: 16),

            // Time Selection
            _buildTimeSelector(),
            const SizedBox(height: 32),

            // Confirm Booking Button
            CustomElevatedButton(
              buttonText: widget.isOrder ? 'Next' : 'Confirm Booking',
              onPressed: _onBookingConfirm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.red),
        title: Text(
          _selectedDate == null
              ? 'Select Date'
              : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
          style: const TextStyle(fontSize: 18),
        ),
        trailing: ElevatedButton(
          onPressed: _pickDate,
          child: const Text('Pick Date'),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.red),
        title: Text(
          _selectedTime == null
              ? 'Select Time'
              : 'Time: ${_selectedTime!.format(context)}',
          style: const TextStyle(fontSize: 18),
        ),
        trailing: ElevatedButton(
          onPressed: _pickTime,
          child: const Text('Pick Time'),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime today = DateTime.now().add(const Duration(days: 1));
    DateTime oneYearLater = today.add(const Duration(days: 365));
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: oneYearLater,
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _onBookingConfirm() async {
    if (_selectedDate != null && _selectedTime != null) {
      if (widget.isOrder) {
        // Navigate to the restaurant menu screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantMenuScreen(
              restaurant: widget.restaurant,
              selectedDate: _selectedDate!,
              selectedTime: _selectedTime!,
              selectedTable: widget.selectedTable,
            ),
          ),
        );
      } else {
        Map<String, dynamic> bookingOrder = {
          'tableNumber': widget.selectedTable + 1,
          'date': _selectedDate!.toIso8601String(),
          'time': _selectedTime!.format(context),
          'restaurantName': widget.restaurant['title'],
          'restaurantImage': widget.restaurant['imageUrl'],
          'orderDetails': null,
          'totalAmount': null,
        };

        await DatabaseHelper().insertBookingOrder(bookingOrder);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
              (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Table ${widget.selectedTable + 1} booked successfully!',
            ),
          ),
        );
      }
    } else {
      // Show an error if no date or time selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text('Please select both date and time'),
        ),
      );
    }
  }
}