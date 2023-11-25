import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

import 'package:medi_minder/entity/journalentry.dart';
import 'package:medi_minder/enums/mood.dart';

class JournalPage extends StatefulWidget {
  @override
  State<JournalPage> createState() => _JournalPageState();
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
          Color lineColor;

          // Set line color based on mood
          switch (entry.mood) {
            case Mood.good:
              lineColor = Colors.green;
              break;
            case Mood.okay:
              lineColor = Colors.lightGreen;
              break;
            case Mood.neutral:
              lineColor = Colors.yellow;
              break;
            case Mood.bad:
              lineColor = Colors.orange;
              break;
            case Mood.terrible:
              lineColor = Colors.red;
              break;
            default:
              lineColor = Colors.white;
          }

          return ListTile(
            title: Text(entry.date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(entry.symptoms, style: TextStyle(fontSize: 16)),
            tileColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            leading: Container(
              width: 8.0,
              color: lineColor,
            ),
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
                  mood: enumFromString(Mood.values, mood),
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

// Rest of the code remains unchanged


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
              'Have you experienced any of these symptoms today?',
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
                      // Handle the case where no symptoms are selected
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

  List<String> getSelectedSymptoms() {
    return selectedSymptoms;
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
                      // Handle the case where mood is not selected
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
                      // Handle the case where feelings are empty
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
            Text(
              'Symptoms:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              entry.symptoms,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 24.0),
            Text(
              'Mood:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              entry.mood.name,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 24.0),
            Text(
              'Feelings:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              entry.feelings,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                _removeEntry(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: Size(400, 60),
                backgroundColor: Colors.red,
              ),
              child: Text('Remove Entry', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _removeEntry(BuildContext context) {
    Navigator.pop(context, true);
  }
}

