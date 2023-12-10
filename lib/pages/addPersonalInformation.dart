import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medi_minder/main.dart';
import 'package:medi_minder/providers/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class addPersonalInformationPage extends StatelessWidget {
  const addPersonalInformationPage({super.key, this.loggedUser});
  final User? loggedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Personal Information",
          style: TextStyle(
            color: Color(0xFF1F41BB),
        fontSize: 24.0,
      ),),
        automaticallyImplyLeading: false,
      ),
      body: addPersonalInformationForm(loggedUser: loggedUser),
    );
  }
}


class addPersonalInformationForm extends StatefulWidget {
  const addPersonalInformationForm({super.key, this.loggedUser});
  final User?  loggedUser;

  @override
  State<addPersonalInformationForm> createState() => _addPersonalInformationFormState();
}

class _addPersonalInformationFormState extends State<addPersonalInformationForm> {
  final _form_key = GlobalKey<FormState>();
  String _username = "";
  String _age = "";
  String _weight = "";
  String _height = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _form_key,
        child: ListView(
            children: [
              const Text(
                "Complete your profile",
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "for a more accurate experience",
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 60,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _username = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Username';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _age = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter your Age';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _height = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter your Height';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FF),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _weight = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter your Weight';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                        'username': user!.displayName,
                        'email': user!.email,
                        'age': '',
                        'height': '',
                        'weight': '',
                      });
                      updateProfile('username', _username);
                      updateProfile('age', _age);
                      updateProfile('height', _height);
                      updateProfile('weight', _weight);
                      if (!mounted) return;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyHomePage(),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F41BB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text("Validate", style: TextStyle(color: Colors.white),)
                ),
              )
            ],
        ),
      )
    );
  }
}