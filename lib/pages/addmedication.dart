import 'package:flutter/material.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Entities
import 'package:medi_minder/entity/medication.dart';
import 'package:medi_minder/entity/dosage.dart';

// Enums
import 'package:medi_minder/enums/dosage.dart';
import 'package:medi_minder/enums/medication.dart';

// Pages
import '../main.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final greyLight = 0xFFF4F4F5;
  DosageTiming? _dosageTime;
  MedicationType? _medicationType;
  String _medicineName = '';
  String _dosage = '';
  bool _isMedicationShortTerm = false;
  DateTime? _selectedDate;
  int _duration = -1;

  Widget _getDosageTimeButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: DosageTiming.values.map((dosageTime) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
            onPressed: () {
              setState(() {
                _dosageTime = dosageTime;
              });
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(_dosageTime == dosageTime ? Colors.black : Colors.grey),
              backgroundColor: MaterialStateProperty.all<Color>(_dosageTime == dosageTime ? Color(greyLight) : Colors.white),
            ),
            child: Text(_getDosageTimeText(dosageTime), style: TextStyle(fontSize: 20,fontWeight: _dosageTime == dosageTime ? FontWeight.bold : FontWeight.normal))),
          );
        }).toList(),
      ),
    );
  }

  String _getDosageTimeText(DosageTiming dosageTime) {
    switch (dosageTime) {
      case DosageTiming.beforeMeal:
        return 'Before Meals';
      case DosageTiming.duringMeal:
        return 'During Meals';
      case DosageTiming.afterMeal:
        return 'After Meals';
      case DosageTiming.whenever:
        return 'Whenever';
      default:
        return '';
    }
  }

  List<Widget> _getMedicationTypeButtons() {
    return MedicationType.values.map((medicationType) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(greyLight),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: IconButton(
            icon: Image.asset(
              'assets/medication/${medicationType.name}.png',
              height: 60
            ),
            onPressed: () {
              setState(() {
                _medicationType = medicationType;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(_medicationType == medicationType ? const Color(0xFFD9D9D9) : Color(greyLight)),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 100),
    ).then((selectedDate) {
      setState(() {
        _selectedDate = selectedDate!;
        _getDaysBetweenDates();
      });
    });
  }

  void _getDaysBetweenDates() {
    setState(() {
      _duration = _selectedDate!.difference(DateTime.now()).inDays;
      _duration = _duration == 0 ? 0 : _duration + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              if (_formKey.currentState!.validate() && _dosageTime != null && _medicationType != null) {
                if (_isMedicationShortTerm && _selectedDate == null) {
                  return;
                }
                else if (!_isMedicationShortTerm) {
                  _selectedDate = null;
                }
                _formKey.currentState!.save();
                Dosage dosage = Dosage(
                  numberOfItems: int.parse(_dosage),
                  timeOfDay: TimeOfDay.now(),
                  timing: _dosageTime!,
                );
                Medication medication = Medication(
                  id: "zrezr", // TODO: put the user id from _auth
                  name: _medicineName,
                  type: _medicationType!,
                  dosages: [dosage],
                  duration: _isMedicationShortTerm ? _duration : -1,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMedicationSchedulePage(),
                    settings: RouteSettings(
                      arguments: medication,
                    ),
                  ),
                );
              }
            });
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
          ),
          child: const Center(child: Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ),
      ),
      body: Form(
        key:_formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1 of 2', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const Text('Add Medication', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _getMedicationTypeButtons(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  hintText: 'e.g. Aspirin',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Medication name is required.';
                  }
                  return null;
                },
                onSaved: (name) {
                  setState(() {
                    _medicineName = name!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Single dose intake',
                  hintText: 'e.g. 1 tablet',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Dosage is required.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Dosage must be a number.';
                  }
                  return null;
                },
                onSaved: (dosage) {
                  setState(() {
                    _dosage = dosage!;
                  });
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _getDosageTimeButtons(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Short term intake?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isMedicationShortTerm,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Color(greyLight),
                    onChanged: (bool value) {
                      setState(() {
                        _isMedicationShortTerm = value;
                      });
                    },
                  ),
                ],
              ),
              _isMedicationShortTerm ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Take Medicine until', style: TextStyle(fontSize: 16)),
                  MaterialButton(
                    onPressed: _showDatePicker,
                    child: Text(_selectedDate == null ? 'Select a Date' : '${_selectedDate?.year}-${_selectedDate?.month}-${_selectedDate?.day}', style: const TextStyle(fontSize: 16)),
                  ),
                ],
              )
              :
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class AddMedicationSchedulePage extends StatefulWidget {
  const AddMedicationSchedulePage({super.key});

  @override
  State<AddMedicationSchedulePage> createState() => _AddMedicationSchedulePageState();
}

class _AddMedicationSchedulePageState extends State<AddMedicationSchedulePage> {
  final _firestore = FirebaseFirestore.instance;
  final greyLight = 0xFFF4F4F5;
  TimeOfDay _timeOfDay = TimeOfDay.now();
  bool _addReminder = false;
  List<Dosage> _dosagesList = [];

  void _updateDosageList(List<Dosage> dosages) {
    setState(() {
      _dosagesList = dosages;
    });
  }

  Future<void> _saveMedication(Medication medication) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;
        final CollectionReference medicationCollection = _firestore.collection('users').doc(userId).collection('Medications');

        final medicationJson = {
          'name': medication.name.toString(),
          'type': medication.type.name,
          'dosages': medication.dosages.map((dosage) => {
            'numberOfItems': dosage.numberOfItems,
            'timeOfDay': {
              'hour' : dosage.timeOfDay.hour,
              'minute' : dosage.timeOfDay.minute
            },
            'timing': dosage.timing.name.toString(),
          }).toList(),
          'duration': medication.duration,
          'notificationsEnabled': medication.notificationsEnabled,
        };
        await medicationCollection.add(medicationJson);
      }
    } catch (e) {
      print('Error while saving the new medication: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Medication medication = ModalRoute.of(context)?.settings.arguments as Medication;
    _updateDosageList(medication.dosages);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage())),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      ),
      floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            Medication finalMedication = Medication(
              id: "zrezr", // TODO: put the user id from _auth
              type: medication.type,
              name: medication.name,
              dosages: _dosagesList,
              duration: medication.duration,
              notificationsEnabled: _addReminder
            );
            _saveMedication(finalMedication);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
          ),
          child: const Center(child: Text('Add New Medication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2 of 2', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const Text('Schedule', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 4,
                  height: 60,
                  child: Container(
                    color: Color(greyLight),
                  ),
                ),
                Image.asset(
                  'assets/medication/${medication.type.name}.png',
                  height: 100,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    medication.duration == -1 ?
                    Text(medication.type.name, style: const TextStyle(fontSize: 16, color: Colors.grey))
                    :
                    Text('${medication.type.name}, ${medication.duration} days left', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Expanded(
                child: ListView.builder(
                  itemCount: _dosagesList.length,
                  itemBuilder: (c, i) {
                    return Dismissible(
                      key: ValueKey(_dosagesList[i]),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dose ${i + 1}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: _dosagesList[i].timeOfDay,
                                  initialEntryMode: TimePickerEntryMode.dial,
                                ).then((time) {
                                  if (time != null) {
                                    setState(() {
                                      _timeOfDay = time;
                                    });
                                  }
                                });
                              },
                              child: Text('${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _dosagesList.removeAt(i);
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add',
              iconSize: 25,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(greyLight)),
              ),
              onPressed: () {
                setState(() {
                  medication.dosages.add(
                    Dosage(
                      numberOfItems: medication.dosages[0].numberOfItems,
                      timeOfDay: TimeOfDay.now(),
                      timing: DosageTiming.whenever,
                    )
                  );
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Switch(
                  value: _addReminder,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Color(greyLight),
                  onChanged: (bool value) {
                    setState(() {
                      _addReminder = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}