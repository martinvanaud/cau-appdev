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
        body: const RegisterForm()
    );
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
  String email = '';
  String password = '';

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
                      final newUser = await _authentication.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      if (newUser != null) {
                        // After successful registration, add user data to Firestore
                        await _addUserDataToFirestore(newUser.user!.uid);

                        _formKey.currentState!.reset();
                      }
                    } catch (e) {
                      // Handle registration errors
                      print('Error during registration: $e');
                    }
                    if (!mounted) return;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
                  },
                  child: const Text('Enter')
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('If you already registered ,'),
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text('login with your email')
                  )
                ],
              ),
            ],
          )
      ),
    );
  }

  Future<void> _addUserDataToFirestore(String userId) async {
    try {
      final CollectionReference usersCollection = _firestore.collection('users');

      // Add a new document for the user
      await usersCollection.doc(userId).set({
        // Additional user data can be added here if needed
      });

      // Add subcollections for journalEntries and medications
      await usersCollection.doc(userId).collection('journalEntries').doc().set({});
      await usersCollection.doc(userId).collection('medications').doc().set({});

    } catch (e) {
      print('Error adding user data to Firestore: $e');
    }
  }
}
