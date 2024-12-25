import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seatview/API/reservation_services.dart';
import 'package:seatview/Main/RestaurantMenuScreen.dart';
import 'package:seatview/Main/MainScreen.dart';

class BookingTime extends StatefulWidget {
  final String selectedTable;
  final String selectedTableId;
  final bool isOrder;
  final Map<String, dynamic> restaurant;
  final String? token; // Token for API authentication

  const BookingTime({
    required this.selectedTable,
    required this.selectedTableId,
    required this.isOrder,
    required this.restaurant,
    this.token,
    Key? key,
  }) : super(key: key);

  @override
  _BookingTimeState createState() => _BookingTimeState();
}

class _BookingTimeState extends State<BookingTime> {
  DateTime ?_selectedDate;
  TimeOfDay ?_selectedTime;
  bool _isLoading = false;

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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have selected Table ${widget.selectedTable}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 16),
                _buildTimeSelector(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    if (widget.isOrder) {
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
                      _onBookingConfirm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.isOrder ? 'Next' : 'Confirm Booking',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
              : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
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
      setState(() => _isLoading = true);

      try {
        final reservationService = ReservationService();
        final response = await reservationService.createReservation(
          token: widget.token ??'',
          tableId: widget.selectedTableId,
          restaurantId: widget.restaurant['id'],
          date: DateFormat('MM-dd-yyyy').format(_selectedDate!),
          time: _selectedTime!.format(context),
          mealId: [], // Empty for now; add ordered meals if applicable.
        );

        if (response['message'] == 'Reservation created successfully') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(userRole:'user',
            )),
                (Route<dynamic> route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Table ${widget.selectedTable} booked successfully!'),
            ),
          );
        } else {
          throw Exception(response['message'] ?? 'Error during reservation.');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to book table: $error'),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please select both date and time.'),
        ),
      );
    }
  }
}
