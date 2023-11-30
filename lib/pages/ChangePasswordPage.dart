import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key, this.loggedUser});
  final User? loggedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: ChangePasswordForm(loggedUser: loggedUser),
    );
  }
}


class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key, this.loggedUser});
  final User?  loggedUser;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _form_key = GlobalKey<FormState>();
  String password = "";
  String confirmPassword = "";
  @override

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: _form_key,
          child: ListView(
            children: [
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'new password'
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 30,),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'confim password'
                ),
                onChanged: (value) {
                  confirmPassword = value;
                },
              ),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: (
                  ) async {
                if (password == confirmPassword) {
                  await widget.loggedUser?.updatePassword(password);
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }, style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set the button color to blue
              ), child: const Text("enter", style: TextStyle(color: Colors.black),),
              ),
            ],
          )
      ),
    );
  }
}
