import 'package:flutter/material.dart';
import 'package:medi_minder/pages/register.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Login here',
            style: TextStyle(
              color: Color(0xFF1F41BB),
              fontSize: 24.0,
            ),
          ),
        ),
        body: const LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool saving = false;
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: saving,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Welcome back you've",
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "been missed!",
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
                    labelText: 'Email',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
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
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      setState(() {
                        saving = true;
                      });
                    } catch (e) {
                      print(e);
                    }
                    final currentUser =
                        await _authentication.signInWithEmailAndPassword(
                            email: email, password: password);

                    if (currentUser.user != null) {
                      _formKey.currentState!.reset();
                      setState(() {
                        saving = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F41BB),
                  // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Set the border radius
                  ),
                  minimumSize:
                      const Size(double.infinity, 60), // Set the button height
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white, // Set the text color
                    fontSize: 20.0, // Set the text font size
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Create a new account',
                      style: TextStyle(color: Color(0xFF1F41BB)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
