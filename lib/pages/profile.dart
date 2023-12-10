import 'dart:math';

import 'package:flutter/material.dart';
import 'ChangePasswordPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:medi_minder/pages/changepassword.dart';

import 'package:medi_minder/entity/profile.dart';

import 'package:medi_minder/providers/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Stream<Profile?> getUserProfileFuture;

  @override
  void initState() {
    super.initState();
    getUserProfileFuture = getUserProfileStream();
  }

  Future<void> fetchProfileData() async {
    DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(loggedUser!.uid)
        .get();

    Map<String, dynamic>? data = profileSnapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      setState(() {
        _username = data['username'] ?? '';
        _age = data['age'] ?? '';
        _height = data['height'] ?? '';
        _weight = data['weight'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<Profile?>(
        stream: getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Profile? userProfile = snapshot.data;
            return buildProfilePage(userProfile);
          } else {
            return const Center(child: Text('No user profile available'));
          }
        },
      ),
    );
  }

  Widget buildProfilePage(Profile? userProfile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(''), // Update this accordingly
                ),
                const SizedBox(height: 30.0),
                Text(
                  userProfile?.username ?? 'Username not available',
                  style: const TextStyle(fontSize: 20.0),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text(
              'Profile informations',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            children: [
              EditableProfileField(
                title: 'Username',
                value: userProfile?.username ?? '',
                onEditComplete: (newValue) => updateProfile('username', newValue),
              ),
              ListTile(
                title: Text("Email: ${userProfile?.email}"),
              ),
              EditableProfileField(
                title: 'Age',
                value: userProfile?.age ?? '',
                onEditComplete: (newValue) => updateProfile('age', newValue),
              ),
              EditableProfileField(
                title: 'Height',
                value: userProfile?.height ?? '',
                onEditComplete: (newValue) => updateProfile('height', newValue),
              ),
              EditableProfileField(
                title: 'Weight',
                value: userProfile?.weight ?? '',
                onEditComplete: (newValue) => updateProfile('weight', newValue),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            children: [
              ListTile(
                title: const Text('change password'),
                trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "Change Password",
                      style: TextStyle(color: Colors.black),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditableProfileField extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Function(String) onEditComplete;

  const EditableProfileField({
    Key? key,
    required this.title,
    required this.value,
    this.icon = Icons.edit,
    required this.onEditComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('$title: $value'),
      trailing: IconButton(
        icon: Icon(icon),
        onPressed: () async {
          final TextEditingController controller = TextEditingController(text: value);
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Edit $title'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your $title',
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Validate'),
                    onPressed: () {
                      if (controller.text.trim().isEmpty) {
                        // If field is empty, show SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in the $title'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        Navigator.of(context).pop();
                        onEditComplete(controller.text);
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
