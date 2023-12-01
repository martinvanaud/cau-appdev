import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: const RegisterForm());
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await _authentication.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      User? user = userCredential.user;
                      if (user != null) {
                        // Update the user's profile with the username and wait for it to complete
                        await user.updateProfile(displayName: username).then((_) async {
                          // After updating, reload the user's profile
                          await user!.reload();

                          // Re-fetch the user to get updated profile
                          user = FirebaseAuth.instance.currentUser;

                          // Store additional user information in Firestore
                          await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                            'username': user!.displayName,
                            'email': user!.email,
                            'age': '',
                            'height': '',
                            'weight': '',
                            // Add other fields as needed
                          });

                          _formKey.currentState!.reset();
                          if (!mounted) return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyHomePage())
                          );
                        });
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        _showErrorSnackbar('Please provide a stronger password.');
                      } else if (e.code == 'email-already-in-use') {
                        _showErrorSnackbar('This user already exists, please login.');
                      } else {
                        _showErrorSnackbar('Login failed: ${e.message}');
                      }
                    } catch (e) {
                      _showErrorSnackbar('An unexpected error occurred.');
                    }
                  },
                  child: const Text('Enter')),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('If you already registered ,'),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('login with your email'))
                ],
              ),
            ],
          )),
    );
  }
}
