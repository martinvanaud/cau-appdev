import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:medi_minder/entity/journalentry.dart';
import 'package:medi_minder/enums/mood.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalPage extends StatefulWidget {
  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> with TickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
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
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;
        final querySnapshot = await _firestore.collection('users').doc(userId).collection('journalEntries').get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            journalEntries = querySnapshot.docs.map((doc) => JournalEntry.fromJson(doc.data() as Map<String, dynamic>)).toList();
            _events = _groupEventsByDate(journalEntries);
          });
        }
      }
    } catch (e) {
      _printError('Error loading journal entries: $e');
    }
  }

  Future<void> _saveJournalEntries() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;
        final CollectionReference journalCollection = _firestore.collection('users').doc(userId).collection('journalEntries');

        final jsonList = journalEntries.map((entry) => entry.toJson()).toList();

        for (var entry in jsonList) {
          await journalCollection.add(entry);
        }

        setState(() {
          _events = _groupEventsByDate(journalEntries);
        });
      }
    } catch (e) {
      _printError('Error saving journal entries: $e');
    }
  }

  Map<DateTime, List<dynamic>> _groupEventsByDate(List<JournalEntry> entries) {
    Map<DateTime, List<dynamic>> events = {};

    for (var entry in entries) {
      DateTime date = DateTime.parse(entry.date.substring(0, 10));

      events[date] ??= [];
      events[date]!.add(entry);
    }

    return events;
  }


  bool _hasJournalForToday() {
    final today = DateTime.now().toString().substring(0, 10);
    return journalEntries.any((entry) => entry.date.startsWith(today));
  }

  Widget _buildJournalButtonOrText() {
    if (_hasJournalForToday()) {
      return Center(
        child: Text(
          'Good job! Journal added for today.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () async => _addJournalEntry(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              minimumSize: Size(double.infinity, 60),
              backgroundColor: Colors.blue,
            ),
            child: Text('Add Journal for Today', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      );
    }
  }

  void _addJournalEntry() async {
    final symptoms = await Navigator.push(context, MaterialPageRoute(builder: (context) => SymptomsEntryPage()));

    if (symptoms != null) {
      final mood = await Navigator.push(context, MaterialPageRoute(builder: (context) => MoodEntryPage()));

      if (mood != null) {
        final feelings = await Navigator.push(context, MaterialPageRoute(builder: (context) => FeelingsEntryPage()));

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Journal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
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
          _buildOverviewTab(),
          // Calendar Tab
          _buildCalendarTab(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: FloatingActionButton(
          onPressed: () async => _addJournalEntry(),
          tooltip: 'Add Journal Entry',
          backgroundColor: Colors.blue.shade800,
          shape: const CircleBorder(),
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35.0,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildJournalButtonOrText(),
        ),
        const SizedBox(height: 10,),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Recent Journal Entries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: _buildRecentJournalEntries(),
        ),
      ],
    );
  }

  Widget _buildCalendarTab() {
    return Column(
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
              _events = _groupEventsByDate(journalEntries);
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
              ? _buildEventList(_events[_selectedDate]!)
              : const Center(
            child: Text(
              'No entries for this date.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForMood(Mood mood) {
    switch (mood) {
      case Mood.good:
        return Colors.green;
      case Mood.okay:
        return Colors.lightGreen;
      case Mood.neutral:
        return Colors.yellow;
      case Mood.bad:
        return Colors.orange;
      case Mood.terrible:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  Widget _buildRecentJournalEntries() {
    return ListView.builder(
      itemCount: journalEntries.length > 10 ? 10 : journalEntries.length,
      itemBuilder: (context, index) {
        final entry = journalEntries[index];
        Color lineColor = _getColorForMood(entry.mood);
        return _buildJournalListTile(entry, lineColor);
      },
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final entry = events[index];
        Color lineColor = _getColorForMood(entry.mood);
        return _buildJournalListTile(entry, lineColor);
      },
    );
  }


  Widget _buildJournalListTile(JournalEntry entry, Color lineColor) {
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
        onTap: () async => _navigateToJournalDetailPage(entry),
      ),
    );
  }

  void _navigateToJournalDetailPage(JournalEntry entry) async {
    final removeEntry = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JournalDetailPage(entry: entry)),
    );

    if (removeEntry == true) {
      setState(() {
        journalEntries.remove(entry);
        _saveJournalEntries(); // Save entries after removal
      });
    }
  }

  void _printError(String message) {
    print('Error: $message');
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
