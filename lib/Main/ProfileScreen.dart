import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/model/user.dart';
import 'ProfileUpdateScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final token = userProvider.token;

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
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/default_avatar.png')
                      as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.phone,
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
                leading: Icon(Icons.person, color: Colors.red[600]),
                title: const Text('Manage Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileUpdateScreen(
                        name: user.name,
                        phoneNumber: user.phone,
                        onUpdate: (updatedName, updatedPhoneNumber) {
                          setState(() {
                            userProvider.setUserData(
                              UserModel(
                                id: user.id,
                                name: updatedName,
                                email: user.email,
                                phone: updatedPhoneNumber,
                                isConfirmed: user.isConfirmed,
                              ),
                              token!,
                            );
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.payment, color: Colors.red[600]),
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
                leading: Icon(Icons.notifications, color: Colors.red[600]),
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
                    // Call the logout function from UserProvider
                    await userProvider.logout();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully')),
                    );

                    // Navigate to the login screen after logout
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'login',
                          (route) => false,
                    );
                  } catch (e) {
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
