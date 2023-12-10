import 'package:flutter/material.dart';

import 'package:medi_minder/pages/login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image widget added here
              Image.asset(
                'assets/welcome.png', // Replace with your image path
                height: 300,
              ),
              const Text(
                'Manage easily your medication',
                style: TextStyle(
                  color: Color(0xFF1F41BB),
                  fontSize: 40.0,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Explore your calendar with all the medications and create your own daily health diary',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F41BB), // Set the background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Set the border radius
                  ),
                  minimumSize: const Size(double.infinity, 60), // Set the button height
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.white, // Set the text color
                    fontSize: 20.0, // Set the text font size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
