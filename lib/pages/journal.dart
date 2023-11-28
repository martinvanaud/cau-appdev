import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

import 'package:medi_minder/entity/journalentry.dart';
import 'package:medi_minder/enums/mood.dart';

class JournalPage extends StatefulWidget {
  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  Map<DateTime, List<dynamic>> _events = {};

  List<JournalEntry> journalEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = DateTime.parse(DateTime.now().toString().substring(0, 10));
    _loadJournalEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/journal_entries.txt');

      if (file.existsSync()) {
        final contents = await file.readAsString();

        if (contents.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(contents);

          setState(() {
            journalEntries = jsonList.map((entry) => JournalEntry.fromJson(entry)).toList();
            _events = groupEventsByDate(journalEntries);
          });
        }
      }
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }


  Map<DateTime, List<dynamic>> groupEventsByDate(List<JournalEntry> entries) {
    Map<DateTime, List<dynamic>> events = {};

    for (var entry in entries) {
      DateTime date = DateTime.parse(entry.date.substring(0, 10));

      if (events[date] == null) {
        events[date] = [];
      }

      events[date]!.add(entry);
    }

    return events;
  }


  Future<void> _saveJournalEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/journal_entries.txt');

      final jsonList = journalEntries.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await file.writeAsString(jsonString);

      setState(() {
        _events = groupEventsByDate(journalEntries);
      });
    } catch (e) {
      print('Error saving journal entries: $e');
    }
  }


  bool hasJournalForToday() {
    final today = DateTime.now().toString().substring(0, 10);
    return journalEntries.any((entry) => entry.date.startsWith(today));
  }

  Widget buildJournalButtonOrText() {
    if (hasJournalForToday()) {
      return Center(
        child: Text(
          'Good job! Journal added for today.',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
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
                    MaterialPageRoute(
                        builder: (context) => FeelingsEntryPage()),
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              minimumSize: Size(double.infinity, 60),
              backgroundColor: Colors.blue,
            ),
            child: Text('Add Journal for Today',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Journal',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildJournalButtonOrText(),
              ),
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Recent Journal Entries',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: journalEntries.length > 10 ? 10 : journalEntries.length,
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

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          entry.date,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(entry.symptoms, style: TextStyle(fontSize: 16)),
                        tileColor: Colors.transparent,
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Calendar Tab
          Column(
            children: [
              TableCalendar(
                focusedDay: _selectedDate,
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2023, 12, 31),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = DateTime.parse(selectedDay.toString().substring(0, 10));

                    // Ensure events are loaded for the selected date
                    _events = groupEventsByDate(journalEntries);
                  });
                },

                eventLoader: (date) {
                  return _events[date] ?? [];
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              // Content for the selected date
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Content for ${_selectedDate.toLocal().toString().substring(0, 10)}:',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: _events[_selectedDate] != null && _events[_selectedDate]!.isNotEmpty
                    ? ListView.builder(
                  itemCount: _events[_selectedDate]!.length,
                  itemBuilder: (context, index) {
                    final entry = _events[_selectedDate]![index];
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

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          entry.date,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(entry.symptoms, style: TextStyle(fontSize: 16)),
                        tileColor: Colors.transparent,
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
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Text(
                    'No entries for this date.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ], // Closing square bracket added here
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
                      final symptoms =
                          selectedSymptoms.join(', '); // Join selected symptoms
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
                  child: Text('Next',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
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
          backgroundColor: isSelected ? Colors.blue : Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child:
            Text(symptom, style: TextStyle(fontSize: 16, color: Colors.white)),
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
                  child: Text('Next',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
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
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
              child: TextField(
                controller: _feelingsController,
                decoration: InputDecoration(
                  labelText: 'Write down notes and feelings from today',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // Set the number of lines
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    final feelings = _feelingsController.text;
                    if (feelings.isNotEmpty) {
                      Navigator.pop(context,
                          feelings); // Return feelings to the previous page
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
                  child: Text('Done',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
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
              child: Text('Remove Entry',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
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
