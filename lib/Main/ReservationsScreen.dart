import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seatview/model/user.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  Map<String, List<Map<String, String>>> weeklyReservations = {}; // Dynamic data map
  bool isLoading = true; // Loading indicator
  bool hasError = false; // Error indicator


  @override
  void initState() {
    super.initState();
    fetchReservations(); // Fetch reservations from the API
  }

  Future<void> fetchReservations() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token ?? '';
    final url = Uri.parse('https://restaurant-reservation-sys.vercel.app/reservations/restaurant/67769fff29bc3a6e219576c2');

    try {
      final response = await http.get(url, headers: {'token': token});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> reservations = data['reservations'];
          Map<String, List<Map<String, String>>> tempReservations = {};

          // Parse reservations into a weekly format
          for (var reservation in reservations) {
            String day = _getDayFromDate(reservation['date']); // Get day from date
            tempReservations.putIfAbsent(day, () => []); // Initialize list if not present

            tempReservations[day]?.add({
              'name': reservation['userId']['name'] ?? 'Unknown',
              'time': reservation['time'] ?? 'Unknown Time',
              'table': reservation['tableId']?['tableNumber'] ?? 'Unknown Table',
            });
          }

          setState(() {
            weeklyReservations = tempReservations;
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
          });
        }
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      setState(() {
        hasError = true;
      });
    }
  }

  String _getDayFromDate(String date) {
    try {
      final DateTime parsedDate = DateFormat('MM-dd-yyyy').parseStrict(date);
      return DateFormat('EEEE').format(parsedDate); // Get day of the week
    } catch (e) {
      return 'Unknown Day'; // Fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reservations"),
        backgroundColor: Colors.red[900],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : hasError
          ? const Center(
        child: Text(
          'Error loading reservations. Please try again.',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: weeklyReservations.entries
            .map(
              (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ),
              entry.value.isEmpty
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "No reservations for ${entry.key}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
                  : Column(
                children: entry.value.map((reservation) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.red),
                      title: Text(
                        reservation["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "Time: ${reservation["time"]}\nTable: ${reservation["table"]}"),
                      trailing: const Icon(Icons.event_seat, color: Colors.green),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}