import 'package:flutter/material.dart';
import 'package:seatview/API/DatabaseHelper_BookedTables.dart';
import 'package:seatview/Components/ElevatedButton.dart';
import 'package:seatview/Main/RestaurantMenuScreen.dart';
import 'package:seatview/Main/MainScreen.dart';

List<Map<String, dynamic>> bookedTables = [];

class BookingTime extends StatefulWidget {
  final int selectedTable;
  final bool isOrder;
  final Map<String, dynamic> restaurant; // Add restaurant parameter

  const BookingTime({
    required this.selectedTable,
    required this.isOrder,
    required this.restaurant, // Include restaurant in the constructor
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
            Text(
              'You selected Table ${widget.selectedTable + 1}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    DateTime today = DateTime.now();
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
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : 'Time: ${_selectedTime!.format(context)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null && pickedTime != _selectedTime) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                  child: const Text('Pick Time'),
                ),
              ],
            ),
            const SizedBox(height: 32),


      CustomElevatedButton(
      buttonText: widget.isOrder ? 'Next' : 'Confirm',
        onPressed: () async {
        if (widget.isOrder==false) {
          if (_selectedDate != null && _selectedTime != null) {
            Map<String, dynamic> booking = {
              'tableNumber': widget.selectedTable + 1,
              'date': _selectedDate!.toIso8601String(),
              'time': _selectedTime!.format(context),
              'restaurantName': widget.restaurant['title'],
              'restaurantImage': widget.restaurant['imageUrl'],
            };

            await DatabaseHelper().insertBooking(booking);

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
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: const Text('Please select a date and time'),
              ),
            );
          }
        }else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantMenuScreen(
                restaurant: widget.restaurant,
                selectedDate: _selectedDate!,
                selectedTime: _selectedTime!,
              ),
            ), // Remove all previous routes
          );
        }
        },
      ),

      ],
        ),
      ),
    );
  }
}
