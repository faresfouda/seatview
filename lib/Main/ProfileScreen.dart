import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/auth_service.dart';
import 'package:seatview/Main/ChangePasswordScreen.dart';
import 'package:seatview/model/user.dart';
import 'ProfileUpdateScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? _imageFile;
  bool _isLoading = false;  // Add a loading state for the account deletion process
  bool _isProfileLoading = true; // Loading state for profile data

  @override
  void initState() {
    super.initState();
    // Fetch profile data when the screen is initialized
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.getProfileData();  // Fetch the profile data using the provided token
      setState(() {
        _isProfileLoading = false; // Set loading to false once data is fetched
      });
    } catch (e) {
      setState(() {
        _isProfileLoading = false; // Set loading to false even on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _showDeleteAccountDialog(String? token, UserProvider userProvider) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog when the user cancels
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // Cancel button color
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (token != null) {
                              setState(() {
                                _isLoading = true; // Show loading indicator
                              });

                              final authService = AuthService();
                              final result = await authService.deleteAccount(token: token);

                              setState(() {
                                _isLoading = false; // Stop loading indicator after operation completes
                              });

                              if (result['success']) {
                                // Perform logout and navigate to the login screen
                                await userProvider.logout();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'])),
                                );

                                // Delay navigation to allow UI updates (e.g., logout UI change)
                                Future.delayed(Duration(milliseconds: 500), () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    'login',
                                        (route) => false,
                                  );
                                });
                              } else {
                                // Show error message if deletion failed
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'])),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: No token available')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Delete button color
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

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
      body: _isProfileLoading
          ? const Center(child: CircularProgressIndicator()) // Show a loading spinner until profile is loaded
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileSection(user!, userProvider),
              const SizedBox(height: 20),
              _buildSectionHeader('My Account'),
              _buildAccountSettings(user, userProvider.token, userProvider),
              const SizedBox(height: 20),
              _buildSectionHeader('Others'),
              _buildOtherSettings(userProvider, userProvider.token),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel user, UserProvider userProvider) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Consumer<UserProvider>(builder: (context, userProvider, child) {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: user.image?.secureUrl.isNotEmpty ?? false
                      ? NetworkImage(user.image!.secureUrl)
                      : const NetworkImage(
                      'https://i.pinimg.com/474x/6d/10/74/6d107462bcc8f71fe80bb1cf6b0d3ab7.jpg'), // Default image
                );
              })
            ],
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
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.phone.isNotEmpty ? user.phone : 'No phone number provided',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings(UserModel user, String? token, UserProvider userProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: Colors.red[600]),
            title: const Text('Manage Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileUpdateScreen(
                    token: token,
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
                            role: user.role,
                          ),
                          token ?? '',
                        );
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.red[600]),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen(
                    token: token,
                    onPasswordChanged: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password has been updated.')),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSettings(UserProvider userProvider, String? token) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red[600]),
            title: const Text('Delete Account'),
            onTap: () async {
              await _showDeleteAccountDialog(token, userProvider);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              try {
                await userProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                      (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
