import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:medi_minder/pages/changepassword.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;

    if (user != null) {
      loggedUser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
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
              child: const Column(
                children: [
                  SizedBox(height: 30.0),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(''),
                  ),
                  SizedBox(height: 30.0),
                  Text(
                    'firebase username',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            const ExpansionTile(
              title: Text('Profile informations',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),),
              children: [
                ListTile(
                  title: Text('Name: ...'),
                ),
                ListTile(
                  title: Text('Age: ...'),
                ),
                ListTile(
                  title: Text('email: ...'),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Settings',
                style: TextStyle(
                  color: Colors.black,
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
                              builder: (context) => ChangePasswordPage(),
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