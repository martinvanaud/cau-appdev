import 'dart:math';

import 'package:flutter/material.dart';
import 'ChangePasswordPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String _username = "";
  String _age = "";
  String _height = "";
  String _weight = "";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchProfileData();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;

    if (user != null) {
      loggedUser = user;
    }
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
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 30.0),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_default.png'),
                  ),
                  const SizedBox(height: 30.0),
                  Text(
                    _username, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ExpansionTile(
              title: const Text('Profile informations',
                style: TextStyle(
                  color: Color(0xFF1F41BB),
                  fontSize: 30,
                ),),
              children: [
                ListTile(
                  title: Text('Username: $_username'),
                ),
                ListTile(
                  title: Text('Age: $_age'),
                ),
                ListTile(
                  title: Text("email: ${loggedUser!.email!}"),
                ),
                ListTile(
                  title: Text('Height: $_height'),
                ),
                ListTile(
                  title: Text('Weight: $_weight'),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            ExpansionTile(
              title: const Text('Settings',
                style: TextStyle(
                  color: Color(0xFF1F41BB),
                  fontSize: 30,
                ),),
              children: [
                ListTile(
                  title: const Text('change password'),
                  trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordPage(loggedUser: loggedUser),
                            ));
                      }, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                      child: const Text("Change Password", style: TextStyle(color: Colors.black),)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}