import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/reservation_provider.dart';
import 'package:seatview/Components/theme.dart';
import 'package:seatview/model/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  Map<String, List<Map<String, dynamic>>> weeklyReservations = {};
  bool isLoading = true;
  bool hasError = false;
  bool hasNoReservations = false;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token ?? '';
    final restaurantId = userProvider.user?.restaurant ?? '';

    if (token.isEmpty || restaurantId.isEmpty) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/reservations/restaurant/$restaurantId');

    try {
      final response = await http.get(url, headers: {'token': token});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> reservations = data['reservations'];
          Map<String, List<Map<String, dynamic>>> tempReservations = {};

          if (reservations.isEmpty) {
            setState(() {
              hasNoReservations = true;
              isLoading = false;
            });
            return;
          }

          for (var reservation in reservations) {
            String day = _getDayFromDate(reservation['date']);
            tempReservations.putIfAbsent(day, () => []);
            tempReservations[day]?.add({
              'name': reservation['userId']['name'] ?? 'Unknown',
              'time': reservation['time'] ?? 'Unknown Time',
              'table': reservation['tableId']?['tableNumber'] ?? 'Unknown Table',
              'mealId': reservation['mealId'] ?? [],
              'status': reservation['status'] ?? 'Unknown Status',
              'id': reservation['_id'] ?? '',
            });
          }

          setState(() {
            weeklyReservations = tempReservations;
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String _getDayFromDate(String date) {
    try {
      final DateTime parsedDate = DateFormat('MM-dd-yyyy').parseStrict(date);
      return DateFormat('EEEE').format(parsedDate);
    } catch (e) {
      return 'Unknown Day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Reservations"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(
        child: Text(
          'Error loading reservations. Please try again.',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : hasNoReservations
          ? const Center(
        child: Text(
          "No reservations available.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: weeklyReservations.entries
            .map(
              (entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  return InkWell(
                    onTap: () => showReservationDetails(context, reservation),
                    child: Card(
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
                      ),
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

  // Show reservation details method (as before)
  void showReservationDetails(BuildContext context, Map<String, dynamic> reservation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity, // Set width to infinity
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reservation Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red[600]),
              ),
              const SizedBox(height: 16),
              Text("Name: ${reservation["name"]}"),
              Text("Time: ${reservation["time"]}"),
              Text("Table: ${reservation["table"]}"),
              Text("Status: ${reservation["status"]}"),
              const SizedBox(height: 16),
              Text("Meals:"),
              // Display meal details if available
              if (reservation["mealId"] != null && reservation["mealId"].isNotEmpty)
                ...reservation["mealId"].map<Widget>((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "${meal["meal"]["name"]} - \$${meal["meal"]["price"]} (Quantity: ${meal["quantity"]})",
                    ),
                  );
                }).toList(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
