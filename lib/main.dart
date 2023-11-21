import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(),
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
    HomePage(),
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Page'),
    );
  }
}

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<JournalEntry> journalEntries = [];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/journal_entries.txt');

      if (file.existsSync()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);

        setState(() {
          journalEntries = jsonList
              .map((entry) => JournalEntry.fromJson(entry))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }

  Future<void> _saveJournalEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/journal_entries.txt');

      final jsonList = journalEntries.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving journal entries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Journal'),
      ),
      body: ListView.builder(
        itemCount: journalEntries.length,
        itemBuilder: (context, index) {
          final entry = journalEntries[index];
          return ListTile(
            title: Text(entry.date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(entry.symptoms, style: TextStyle(fontSize: 16)),
            onTap: () async {
              final removeEntry = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalDetailPage(entry: entry),
                ),
              );

              if (removeEntry == true) {
                setState(() {
                  journalEntries.remove(entry);
                  _saveJournalEntries(); // Save entries after removal
                });
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEntry = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MultiStepJournalEntryPage()),
          );

          if (newEntry != null) {
            setState(() {
              journalEntries.add(newEntry);
              _saveJournalEntries(); // Save entries when a new one is added
            });
          }
        },
        tooltip: 'Add Journal Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Page'),
    );
  }
}

class JournalEntry {
  final String date;
  final String symptoms;
  final String feelings;

  JournalEntry({required this.date, required this.symptoms, required this.feelings});

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'symptoms': symptoms,
      'feelings': feelings,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: json['date'],
      symptoms: json['symptoms'],
      feelings: json['feelings'],
    );
  }
}

class MultiStepJournalEntryPage extends StatefulWidget {
  @override
  _MultiStepJournalEntryPageState createState() => _MultiStepJournalEntryPageState();
}

class _MultiStepJournalEntryPageState extends State<MultiStepJournalEntryPage> {
  late TextEditingController _symptomsController;
  late TextEditingController _feelingsController;

  int _currentStep = 0;
  static const int _totalSteps = 2;

  @override
  void initState() {
    super.initState();
    _symptomsController = TextEditingController();
    _feelingsController = TextEditingController();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _feelingsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _saveEntry() {
    final date = DateTime.now().toString().substring(0, 16);
    final symptoms = _symptomsController.text;
    final feelings = _feelingsController.text;

    if (symptoms.isNotEmpty) {
      Navigator.pop(
        context,
        JournalEntry(date: date, symptoms: symptoms, feelings: feelings),
      );
    } else {
      // Handle case where symptoms are empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Journal Entry'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepTapped: (step) => _nextStep(),
        onStepCancel: () => Navigator.pop(context),
        steps: [
          Step(
            title: Text('Symptoms'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step ${_currentStep + 1} of $_totalSteps'),
                TextField(
                  controller: _symptomsController,
                  decoration: InputDecoration(labelText: 'Enter Symptoms'),
                ),
              ],
            ),
            isActive: _currentStep == 0,
          ),
          Step(
            title: Text('Feelings'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step ${_currentStep + 1} of $_totalSteps'),
                TextField(
                  controller: _feelingsController,
                  decoration: InputDecoration(labelText: 'Enter Feelings'),
                ),
              ],
            ),
            isActive: _currentStep == 1,
          ),
        ],
      ),
      floatingActionButton: _currentStep == _totalSteps - 1
          ? FloatingActionButton(
        onPressed: _saveEntry,
        tooltip: 'Save',
        child: Icon(Icons.save),
      )
          : null,
    );
  }
}

class JournalDetailPage extends StatelessWidget {
  final JournalEntry entry;

  JournalDetailPage({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.date),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Symptoms:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4.0),
            Text(entry.symptoms, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 18.0),
            const Text(
              'Feelings:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4.0),
            Text(entry.feelings, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                _removeEntry(context);
              },
              child: const Text('Remove Entry', style: TextStyle(color: Colors.red, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  void _removeEntry(BuildContext context) {
    Navigator.pop(context, true); // Return true to indicate removal
  }
}


