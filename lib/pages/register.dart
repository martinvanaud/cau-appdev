import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                    final newUser = await _authentication.createUserWithEmailAndPassword(
                        email: email,
                        password: password
                    );

                    if (newUser != null) {
                      _formKey.currentState!.reset();
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
}
