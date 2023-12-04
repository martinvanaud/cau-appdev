import 'package:flutter/material.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: const ChangePasswordForm(),
    );
  }
}


class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

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
                decoration: const InputDecoration(
                    labelText: 'new password'
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 30,),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'confim password'
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(height: 30,),
              ElevatedButton(onPressed: (
                  ) {
                if (password == confirmPassword) {
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
