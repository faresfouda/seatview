import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:seatview/Main/AddMealScreen.dart';
import 'package:seatview/Main/AddTableScreen.dart';
import 'package:seatview/Main/AddVipRoomScreen.dart';
import 'package:seatview/Main/EditMealScreen.dart';
import 'package:seatview/Main/EditMealScreen.dart';
import 'package:seatview/Main/EditTableScreen.dart';
import 'package:seatview/Main/EditVipRoomScreen.dart';
import 'package:seatview/model/user.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<Map<String, dynamic>> tables = [];
  List<Map<String, dynamic>> menuItems = [];
  List<Map<String, dynamic>> vipRooms = []; // Add a list for VIP rooms
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchInventoryData();
  }
  void refreshInventory() {
    fetchInventoryData();
  }



  String getRestaurantId() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.user?.restaurant ?? ''; // Get restaurant ID from UserProvider
  }

  Future<void> fetchInventoryData() async {
    final restaurantId = getRestaurantId();
    if (restaurantId.isEmpty) {
      print('Restaurant ID is null or empty');
      setState(() {
        hasError = true;
      });
      return;
    }

    final tablesUrl = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/tables/restaurant/$restaurantId');
    final menuItemsUrl = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/meals/restaurant/$restaurantId');
    final vipRoomsUrl = Uri.parse(
        'https://restaurant-reservation-sys.vercel.app/vip-rooms/restaurant/$restaurantId'); // Dynamic URL with restaurant ID

    try {
      final tablesResponse = await http.get(tablesUrl);
      final menuResponse = await http.get(menuItemsUrl);
      final vipRoomsResponse = await http.get(vipRoomsUrl); // Fetch VIP rooms

      if (tablesResponse.statusCode == 200 &&
          menuResponse.statusCode == 200 &&
          vipRoomsResponse.statusCode == 200) {
        final tablesData = json.decode(tablesResponse.body);
        final menuData = json.decode(menuResponse.body);
        final vipRoomsData = json.decode(vipRoomsResponse.body);

        setState(() {
          tables = List<Map<String, dynamic>>.from(tablesData['data']);
          menuItems = List<Map<String, dynamic>>.from(menuData['meals']);
          vipRooms = List<Map<String, dynamic>>.from(vipRoomsData['data']); // Parse VIP rooms
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> deleteItem(String itemType, String itemId) async {
    final restaurantId = getRestaurantId();
    if (restaurantId.isEmpty) {
      print('Restaurant ID is null or empty');
      setState(() {
        hasError = true;
      });
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token; // Assuming token is stored in user

    if (token == null) {
      print('Token is null');
      setState(() {
        hasError = true;
      });
      return;
    }

    String deleteUrl;
    if (itemType == 'table') {
      deleteUrl = 'https://restaurant-reservation-sys.vercel.app/tables/delete/$itemId';
    } else if (itemType == 'menu') {
      deleteUrl = 'https://restaurant-reservation-sys.vercel.app/meals/delete/$itemId';
    } else if (itemType == 'vip') {
      deleteUrl = 'https://restaurant-reservation-sys.vercel.app/vip-rooms/delete/$itemId';
    } else {
      print('Invalid item type');
      return;
    }

    // Show confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('This action cannot be undone. Do you want to proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                try {
                  final response = await http.delete(
                    Uri.parse(deleteUrl),
                    headers: {
                      'token': '$token', // Add token to the header
                    },
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      // After successful deletion, refetch the data to reflect the changes
                      fetchInventoryData();
                    });
                  } else {
                    setState(() {
                      hasError = true;
                    });
                  }
                } catch (e) {
                  setState(() {
                    hasError = true;
                  });
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Management"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
        child: Text(
          'Error loading inventory data. Please try again.',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Restaurant Tables",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTableScreen(
                          onUpdate: () {
                          refreshInventory();
                        },),
                      ),
                    );
                  },
                  color: Colors.blueAccent,
                  iconSize: 30,
                ),
              ],
            ),
            SizedBox(height: 8),
            tables.isEmpty
                ? Center(child: Text('No tables available'))
                : ListView.builder(
              itemCount: tables.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final table = tables[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.table_bar,
                        color: Colors.blue),
                    title: Text("Table ${table['tableNumber']}"),
                    subtitle:
                    Text("Capacity: ${table['capacity']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTableScreen(
                                  table: table, // Pass the selected table to the screen
                                  onUpdate: () {
                                    // Refresh table data after update
                                    refreshInventory();
                                  },
                                ),
                              ),
                            );

                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            deleteItem('table', table['_id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menu Items",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMealScreen(onUpdate: ()
                        {
                          refreshInventory();
                        }
                        ),
                      ),
                    );
                  },
                  color: Colors.blueAccent,
                  iconSize: 30,
                ),
              ],
            ),
            SizedBox(height: 8),
            menuItems.isEmpty
                ? Center(child: Text('No menu items available'))
                : ListView.builder(
              itemCount: menuItems.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          menuItem['image']['secure_url']),
                    ),
                    title: Text(menuItem['name']),
                    subtitle: Text("Price: \$${menuItem['price']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMealScreen(
                                  meal: menuItem, // Pass the selected table to the screen
                                  onUpdate: () {
                                    // Refresh table data after update
                                    refreshInventory();
                                  },
                                ),
                              ),
                            );

                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            deleteItem('menu', menuItem['_id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "VIP Rooms",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVipRoomScreen(
                          onUpdate: () {
                            refreshInventory();  // Refresh VIP rooms
                          },
                        ),
                      ),
                    );

                  },
                  color: Colors.blueAccent,
                  iconSize: 30,
                ),
              ],
            ),
            SizedBox(height: 8),
            vipRooms.isEmpty
                ? Center(child: Text('No VIP rooms available'))
                : ListView.builder(
              itemCount: vipRooms.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final vipRoom = vipRooms[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading:
                    Icon(Icons.event_seat, color: Colors.blue),
                    title: Text("Room ${vipRoom['name']}"),
                    subtitle: Text("Capacity: ${vipRoom['capacity']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditVipRoomScreen(
                                  vipRoom: vipRoom,
                                  onUpdate: refreshInventory,  // Pass the callback
                                ),
                              ),
                            );


                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            deleteItem('vip', vipRoom['_id']);
                          },
                        ),
                      ],
                    ),
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
