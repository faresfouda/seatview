import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Main/AddVipRoomScreen.dart';
import 'package:seatview/model/user.dart';


class OwnerHomeScreen extends StatefulWidget {
  @override
  _OwnerHomeScreenState createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  List<Map<String, dynamic>> reservations = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> vipRooms = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchOwnerData();
  }

  Future<void> fetchOwnerData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token ?? '';
    final restaurantId = userProvider.user?.restaurant ?? '';

    if (token.isEmpty || restaurantId.isEmpty) {
      print('Token or restaurant ID is null or empty');
      setState(() {
        hasError = true;
      });
      return;
    }

    final today = DateTime.now();
    final formattedDate = DateFormat('MM-dd-yyyy').format(today);  // Updated format

    // Updated reservations URL with today's date
    final reservationsUrl = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/reservations/restaurant/$restaurantId/day?date=$formattedDate');
    final reviewsUrl = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/reviews/restaurant/$restaurantId');
    final vipRoomsUrl = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/vip-rooms/restaurant/$restaurantId');

    try {
      final headers = {'token': '$token'};

      final reservationsResponse = await http.get(reservationsUrl, headers: headers);
      print('Reservations Response: ${reservationsResponse.body}');

      final reviewsResponse = await http.get(reviewsUrl, headers: headers);
      print('Reviews Response: ${reviewsResponse.body}');

      final vipRoomsResponse = await http.get(vipRoomsUrl, headers: headers);
      print('VIP Rooms Response: ${vipRoomsResponse.body}');

      if (reservationsResponse.statusCode == 200 &&
          vipRoomsResponse.statusCode == 200) {
        final reservationsData = json.decode(reservationsResponse.body);
        final reviewsData = json.decode(reviewsResponse.body);
        final vipRoomsData = json.decode(vipRoomsResponse.body);

        setState(() {
          reservations = List<Map<String, dynamic>>.from(reservationsData['reservations'] ?? []);
          reviews = List<Map<String, dynamic>>.from(reviewsData['reviews'] ?? []);
          vipRooms = List<Map<String, dynamic>>.from(vipRoomsData['vipRooms'] ?? []);
          isLoading = false;
        });
      } else {
        print('HTTP error: ${reservationsResponse.statusCode}, ${reviewsResponse.statusCode}, ${vipRoomsResponse.statusCode}');
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching owner data: $e');
      setState(() {
        hasError = true;
      });
    }
  }


  Future<void> updateReservationStatus(String reservationId, String newStatus) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token ?? '';
    final restaurantId = userProvider.user?.restaurant ?? '';

    if (token.isEmpty || restaurantId.isEmpty) {
      print('Token or restaurant ID is null or empty');
      setState(() {
        hasError = true;
      });
      return;
    }

    final url = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/reservations/$reservationId');
    final headers = {'token': '$token'};
    final body = json.encode({'status': newStatus});

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Reservation status updated');
        fetchOwnerData();  // Refresh the data after updating
      } else {
        print('Failed to update reservation status: ${response.statusCode}');
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      print('Error updating reservation status: $e');
      setState(() {
        hasError = true;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white),
            SizedBox(width: 8),
            Text("Restaurant - Home"),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
        child: Text(
          'Error loading data. Please try again.',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Reservations Section
            Text(
              "Today's Reservations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            reservations.isEmpty
                ? Text('No reservations for today.')
                : ListView.builder(
              itemCount: reservations.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(reservation['userId']['name'] ?? 'Unknown'),
                    subtitle: Text(
                        "Time: ${reservation['time']}\nGuests: ${reservation['tableId']['capacity']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            reservation['status'] ?? 'Pending',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: reservation['status'] == 'Confirmed'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // You can update the status here (e.g., change it to "Confirmed")
                            updateReservationStatus(reservation['_id'], 'Confirmed');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            // Recent Reviews Section
            Text(
              "Recent Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            reviews.isEmpty
                ? Text('No reviews available.')
                : ListView.builder(
              itemCount: reviews.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.star, color: Colors.amber),
                    ),
                    title: Text(review['customerName'] ?? 'Unknown'),
                    subtitle: Text(review['comment'] ?? 'No comment'),
                    trailing: IconButton(
                      icon: Icon(Icons.reply),
                      onPressed: () {
                        // Handle reply action
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // VIP Reserved Rooms Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "VIP Reserved Rooms",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            vipRooms.isEmpty
                ? Text('No VIP rooms reserved.')
                : GridView.builder(
              itemCount: vipRooms.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final room = vipRooms[index];
                return Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.room, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room['roomName'] ?? 'Room',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Reserved: ${room['time'] ?? 'N/A'}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
