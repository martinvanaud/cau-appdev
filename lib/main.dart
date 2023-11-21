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
          final symptoms = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SymptomsEntryPage()),
          );

          if (symptoms != null) {
            final mood = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MoodEntryPage()),
            );

            if (mood != null) {
              final feelings = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeelingsEntryPage()),
              );

              if (feelings != null) {
                final newEntry = JournalEntry(
                  date: DateTime.now().toString().substring(0, 16),
                  symptoms: symptoms,
                  feelings: feelings,
                  mood: mood, // Add mood to the new entry
                );

                setState(() {
                  journalEntries.add(newEntry);
                  _saveJournalEntries(); // Save entries when a new one is added
                });
              }
            }
          }
        },
        tooltip: 'Add Journal Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SymptomsEntryPage extends StatefulWidget {
  @override
  _SymptomsEntryPageState createState() => _SymptomsEntryPageState();
}

class _SymptomsEntryPageState extends State<SymptomsEntryPage> {
  List<String> selectedSymptoms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1 of 3', style: TextStyle(fontSize: 16)),
            Text(
              'Have you experiened any of these symptoms today?',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: buildSymptomButtons(),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedSymptoms.isNotEmpty) {
                      final symptoms = selectedSymptoms.join(', '); // Join selected symptoms
                      Navigator.pop(context, symptoms);
                    } else {
                      // Handle case where no symptoms are selected
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(400, 60),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('Next', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSymptomButtons() {
    final List<String> allSymptoms = [
      'Chills',
      'Chest pain',
      'Constipation',
      'Diarrhea',
      'Dizziness',
      'Fatigue',
      'Fever',
      'Headache',
      'Joint pain',
      'Muscle pain',
      'Nausea',
      'Unusual tiredness',
      'Vomiting',
      'No symptoms'
    ];

    return allSymptoms.map((symptom) {
      final bool isSelected = selectedSymptoms.contains(symptom);
      return ElevatedButton(
        onPressed: () {
          setState(() {
            if (isSelected) {
              selectedSymptoms.remove(symptom);
            } else {
              selectedSymptoms.add(symptom);
            }
          });
        },
        style: ElevatedButton.styleFrom(
          primary: isSelected ? Colors.blue : Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(symptom, style: TextStyle(fontSize: 16, color: Colors.white)),
      );
    }).toList();
  }
}


class MoodEntryPage extends StatefulWidget {
  @override
  _MoodEntryPageState createState() => _MoodEntryPageState();
}

class _MoodEntryPageState extends State<MoodEntryPage> {
  String? selectedMood; // Variable to store the selected mood

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('2 of 3', style: TextStyle(fontSize: 16)),
            Text('What is your overall mood?',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            // Use a Column to display mood options vertically
            Column(
              children: [
                _buildMoodRadioButton('Good'),
                _buildMoodRadioButton('Okay'),
                _buildMoodRadioButton('Neutral'),
                _buildMoodRadioButton('Bad'),
                _buildMoodRadioButton('Terrible'),
              ],
            ),
            const SizedBox(height: 16.0),
            // Draw a line connecting all the circles
            const SizedBox(height: 16.0),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedMood != null) {
                      Navigator.pop(context, selectedMood);
                    } else {
                      // Handle case where mood is not selected
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(400, 60),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('Next', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodRadioButton(String mood) {
    return Row(
      children: [
        Radio<String>(
          value: mood,
          groupValue: selectedMood,
          onChanged: (value) {
            setState(() {
              selectedMood = value;
            });
          },
        ),
        Text(mood, style: TextStyle(fontSize: 18)),
        SizedBox(width: 16.0),
      ],
    );
  }
}



class FeelingsEntryPage extends StatefulWidget {
  @override
  _FeelingsEntryPageState createState() => _FeelingsEntryPageState();
}

class _FeelingsEntryPageState extends State<FeelingsEntryPage> {
  late TextEditingController _feelingsController;

  @override
  void initState() {
    super.initState();
    _feelingsController = TextEditingController();
  }

  @override
  void dispose() {
    _feelingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('3 of 3', style: TextStyle(fontSize: 16)),
            Text('Describe your current feelings',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            TextField(
              controller: _feelingsController,
              decoration: InputDecoration(labelText: 'Enter Feelings'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    final feelings = _feelingsController.text;
                    if (feelings.isNotEmpty) {
                      Navigator.pop(context, feelings); // Return feelings to the previous page
                    } else {
                      // Handle case where feelings are empty
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(400, 60),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('Finish', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class JournalEntry {
  final String date;
  final String symptoms;
  final String feelings;
  final String mood;

  JournalEntry({
    required this.date,
    required this.symptoms,
    required this.feelings,
    required this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'symptoms': symptoms,
      'feelings': feelings,
      'mood': mood,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: json['date'],
      symptoms: json['symptoms'],
      feelings: json['feelings'],
      mood: json['mood'],
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
              'Mood:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4.0),
            Text(entry.mood, style: TextStyle(fontSize: 18)),
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

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Page'),
    );
  }
}

