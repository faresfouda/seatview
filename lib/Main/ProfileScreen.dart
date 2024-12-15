import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileUpdateScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Fares";
  String phoneNumber = "+20 108979 2644";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Info
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150'), // Replace with a user's profile picture
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // My Account Section
              const Text(
                'My Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading:  Icon(Icons.person, color: Colors.red[600]),
                title: const Text('Manage Profile'),
                onTap: () {
                  // Navigate to profile update screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileUpdateScreen(
                        name: name,
                        phoneNumber: phoneNumber,
                        onUpdate: (updatedName, updatedPhoneNumber) {
                          setState(() {
                            name = updatedName;
                            phoneNumber = updatedPhoneNumber;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading:  Icon(Icons.payment, color: Colors.red[600]),
                title: const Text('Payment Methods'),
                onTap: () {
                  // Handle payment methods
                },
              ),
              const SizedBox(height: 20),

              // Others Section
              const Text(
                'Others',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading:  Icon(Icons.notifications, color: Colors.red[600]),
                title: const Text('Notifications'),
                onTap: () {
                  // Handle notifications
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('signed out succesfuly')),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, 'login',(route)=>false);
                  }catch (e) {
                    // Handle sign-out errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }

                },
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}
