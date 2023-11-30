import 'package:flutter/material.dart';
import 'ChangePasswordPage.dart';

import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider
import 'package:provider/provider.dart';
import 'package:medi_minder/providers/medication.dart';

// Pages
import 'package:medi_minder/pages/login.dart';
import 'package:medi_minder/pages/home.dart';
import 'package:medi_minder/pages/journal.dart';
import 'package:medi_minder/pages/profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        MedicationProvider provider = MedicationProvider();
        provider.initializeMedications();
        return provider;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediMinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MyHomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    JournalPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),),
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
